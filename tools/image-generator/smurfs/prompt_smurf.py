from anthropic import Anthropic

client = Anthropic()

SYSTEM_PROMPT = """Sen bir sosyal medya iceriki uzmani ve gorsel prompt muhendisisin.
Turkce gorsel isteklerini, image generation API'leri icin optimize edilmis Ingilizce prompt'lara ceviriyorsun.

Kurallar:
- Prompt her zaman Ingilizce olmali
- Stil, isik, kompozisyon ve atmosfer detaylarini ekle
- Platform formatina gore kompozisyonu ayarla:
  * Feed (kare): Merkezi kompozisyon, dengeli bosluk
  * Story (dikey): Dikey akis, ust/alt bosluk birak, metin alani dusun
  * Banner (yatay): Yatay yayilim, ucte bir kurali
  * OG (genis): Sosyal paylasim karti, net ve okunabilir
- Kurumsal/marka icerigi icin: profesyonel, temiz, modern estetik
- Prompt sonunda negatif prompt da uret (istenmeyen ogeler)
- JSON formatinda yanit ver"""

def generate_prompt(user_request: str, platform: str, extra_context: str = "") -> dict:
    """
    Turkce kullanici istegini platforma gore optimize edilmis prompt'a cevirir.

    Returns:
        dict: {
            "positive_prompt": str,
            "negative_prompt": str,
            "style_notes": str
        }
    """
    platform_labels = {
        "feed": "square (1:1) for social media feed post",
        "story": "vertical (9:16) for Instagram/TikTok story or reels",
        "banner": "wide (16:9) for website hero banner",
        "og": "wide (1.91:1) for Open Graph / Twitter Card",
    }
    platform_label = platform_labels.get(platform, "square (1:1) for social media feed post")

    message = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1000,
        system=SYSTEM_PROMPT,
        messages=[
            {
                "role": "user",
                "content": f"""Kullanici istegi: {user_request}

Platform: {platform_label}
Ek baglam: {extra_context if extra_context else 'Yok'}

Lutfen su JSON formatinda yanit ver (baska hicbir sey yazma):
{{
    "positive_prompt": "...",
    "negative_prompt": "...",
    "style_notes": "..."
}}"""
            }
        ]
    )

    import json
    response_text = message.content[0].text.strip()
    # JSON blogunu temizle
    if "```" in response_text:
        response_text = response_text.split("```")[1]
        if response_text.startswith("json"):
            response_text = response_text[4:]

    return json.loads(response_text.strip())


if __name__ == "__main__":
    result = generate_prompt(
        user_request="14 Subat Sevgililer Gunu icin sirket paylasimi, sicak ve profesyonel",
        platform="feed"
    )
    print(result)
