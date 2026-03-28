import os
import requests
from datetime import datetime
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from config import OPENAI_API_KEY, REPLICATE_API_TOKEN, STABILITY_API_KEY, FORMATS, OUTPUT_DIR


def generate_with_dalle(positive_prompt: str, negative_prompt: str, platform: str) -> str:
    """DALL-E 3 ile gorsel uretir. Dondurur: dosya yolu"""
    from openai import OpenAI
    client = OpenAI(api_key=OPENAI_API_KEY)

    # DALL-E 3 desteklenen boyutlar: 1024x1024, 1024x1792, 1792x1024
    size_map = {
        "feed": "1024x1024",
        "story": "1024x1792",
        "banner": "1792x1024",
        "og": "1792x1024",
    }
    size = size_map.get(platform, "1024x1024")

    full_prompt = positive_prompt
    if negative_prompt:
        full_prompt += f" Avoid: {negative_prompt}"

    response = client.images.generate(
        model="dall-e-3",
        prompt=full_prompt,
        size=size,
        quality="standard",
        n=1,
    )

    image_url = response.data[0].url
    return _download_and_save(image_url, platform, "dalle")


def generate_with_flux(positive_prompt: str, negative_prompt: str, platform: str) -> str:
    """Replicate FLUX 1.1 Pro ile gorsel uretir."""
    import replicate

    aspect_map = {
        "feed": "1:1",
        "story": "9:16",
        "banner": "16:9",
        "og": "16:9",
    }
    aspect_ratio = aspect_map.get(platform, "1:1")

    output = replicate.run(
        "black-forest-labs/flux-1.1-pro",
        input={
            "prompt": positive_prompt,
            "aspect_ratio": aspect_ratio,
            "output_format": "png",
            "output_quality": 90,
            "safety_tolerance": 2,
            "prompt_upsampling": True,
        }
    )

    image_url = str(output)
    return _download_and_save(image_url, platform, "flux")


def generate_with_stability(positive_prompt: str, negative_prompt: str, platform: str) -> str:
    """Stability AI Stable Image Core ile gorsel uretir."""
    aspect_map = {
        "feed": "1:1",
        "story": "9:16",
        "banner": "16:9",
        "og": "16:9",
    }
    aspect_ratio = aspect_map.get(platform, "1:1")

    response = requests.post(
        "https://api.stability.ai/v2beta/stable-image/generate/core",
        headers={
            "authorization": f"Bearer {STABILITY_API_KEY}",
            "accept": "image/*"
        },
        files={"none": ""},
        data={
            "prompt": positive_prompt,
            "negative_prompt": negative_prompt,
            "aspect_ratio": aspect_ratio,
            "output_format": "png",
        },
    )

    if response.status_code != 200:
        raise Exception(f"Stability AI hatasi: {response.status_code} - {response.text}")

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{platform}_{timestamp}_stability.png"
    filepath = os.path.join(OUTPUT_DIR, filename)

    with open(filepath, "wb") as f:
        f.write(response.content)

    return filepath


def _download_and_save(url: str, platform: str, provider: str) -> str:
    """URL'den gorseli indirir ve outputs/ klasorune kaydeder."""
    response = requests.get(url)
    response.raise_for_status()

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{platform}_{timestamp}_{provider}.png"
    filepath = os.path.join(OUTPUT_DIR, filename)

    with open(filepath, "wb") as f:
        f.write(response.content)

    return filepath


GENERATORS = {
    "1": generate_with_dalle,
    "2": generate_with_flux,
    "3": generate_with_stability,
}
