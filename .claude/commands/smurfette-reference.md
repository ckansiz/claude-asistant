# Smurfette - Image Generation Reference

Use this when generating AI images or debugging the image pipeline.

## Turkish Special Days Calendar (Reference)

### Dini Günler
- Ramazan Bayramı (Eid al-Fitr)
- Kurban Bayramı (Eid al-Adha)
- Kandiller: Mevlid, Regaib, Miraç, Berat, Kadir Gecesi

### Milli ve Resmi Günler
- 23 Nisan — Ulusal Egemenlik ve Çocuk Bayramı
- 19 Mayıs — Atatürk'ü Anma, Gençlik ve Spor Bayramı
- 30 Ağustos — Zafer Bayramı
- 29 Ekim — Cumhuriyet Bayramı
- 10 Kasım — Atatürk'ü Anma
- 6 Şubat — Kahramanmaraş Depremleri Anma

### Özel Günler
- 14 Şubat — Sevgililer Günü
- Anneler Günü (2. Pazar, Mayıs)
- Babalar Günü (3. Pazar, Haziran)
- Öğretmenler Günü (24 Kasım)
- Yeni Yıl (1 Ocak)

## Platform Formats

| Platform | Aspect Ratio | Dimensions |
|----------|-------------|------------|
| Instagram/Facebook Story | 9:16 | 1024x1792 |
| Instagram/Facebook Feed | 1:1 | 1024x1024 |
| Web Hero / Banner | 16:9 | 1792x1024 |
| Open Graph / Twitter Card | 1.91:1 | 1200x630 |

## Supported Image APIs

| API | Best For |
|-----|----------|
| DALL-E 3 (OpenAI) | Photorealistic scenes, atmospheric depth, compositional precision |
| FLUX 1.1 Pro (Replicate) | Artistic/painterly styles, strong mood, textural richness |
| Stable Image Core (Stability AI) | Consistent style series, negative prompt control, batch efficiency |

**Default**: DALL-E 3 for photorealistic special day visuals.

## Prompt Structure Template

```json
{
  "positive_prompt": "Cinematic [style] photograph of [subject]. [Setting/environment]. [Lighting description]. [Mood/atmosphere]. [Compositional notes]. [Color palette]. Shot on [camera/lens reference if photorealistic]. --no text",
  "negative_prompt": "generic stock photo, cheesy, cartoonish, text artifacts, watermark, blurry, overexposed, plastic texture, fake smile, corporate clipart, AI-generated look, extra limbs, deformed",
  "creative_rationale": "Why these choices serve the emotion and occasion"
}
```

## 2026 Editorial Aesthetic (Proven Phrases)

These produce consistent, professional results:

```
ultra-fine film grain
ethereal warm haze
shallow depth of field, silky smooth background blur
cinematic color grading, analog warmth, medium format feel
shot on medium format camera
not a stock photo, emotionally real
```

## Negative Prompt Template (Always Use)

```
generic stock photo, cheesy, clipart, heart clipart, kitsch, oversaturated,
cartoonish, plastic, AI-generated look, watermark, text, words, letters,
blurry subject, low quality, corporate clipart
```

## Composition Rules by Format

### Story (9:16)
- Leave clean dark space in upper 25% for text overlay
- Add to prompt: `"clean dark negative space in upper 25% for text overlay"`
- Clear focal point in center-lower-third

### Feed (1:1)
- Balanced, centered subject
- Strong visual hierarchy
- Breathing room around main element

### Banner (16:9)
- Wide panoramic flow
- Rule of thirds
- Breathing room on sides for navigation UI

## Wesoco Brand Colors

Use for Wesoco-internal images:
- Primary: `#0c1727` (dark navy)
- Accent: `#E84445` (vibrant red)
- Logo files: `tools/image-generator/base-pics/`
  - `wesoco-logo-beyaz.svg` — dark backgrounds
  - `wesoco-logo-lacivert.svg` — light backgrounds

## DALL-E 3 Content Filter Workaround

Content that triggers `400 content_policy_violation`:
- Close physical human contact: embracing, kissing, hand-holding
- Prompt keywords: "intimate", "embrace", "couple holding each other", "kiss"

**Workaround**: Use object and atmospheric compositions:
- Single hero object: rose, candle, envelope, ring, coffee cup
- Atmospheric: bokeh lights, scattered leaves, candlelight
- Nature scenes: sunset, starry sky, city night lights

## Direct Image Generation (Bash Pipeline)

If direct agent dispatch fails, use Bash:

```bash
cd /Users/ckansiz/workspace/smurfs
tools/image-generator/.venv/bin/python - <<'EOF'
import sys, os
sys.path.insert(0, 'tools/image-generator')
from smurfs.image_smurf import generate_with_dalle

filepath = generate_with_dalle(
    positive_prompt="Your detailed positive prompt here",
    negative_prompt="Your negative prompt here",
    platform="story",           # story | feed | banner | og
    overlay_text="Optional Turkish text"
)
print(os.path.abspath(filepath))
EOF
```

Platform options:
- `"story"` → 9:16 Story format
- `"feed"` → 1:1 Feed format
- `"banner"` → 16:9 Web banner
- `"og"` → 1.91:1 Open Graph

Alternatively use `generate_with_flux()` or `generate_with_stability()` for other APIs.

## Quality Checklist

Before delivering an image:

- [ ] Does it feel cinematic, not stock-photo?
- [ ] Is there clean space for text overlays?
- [ ] Does the color palette align with the client's brand?
- [ ] Does the emotion match the occasion? (e.g., no cheerful colors for memorial days)
- [ ] Is Turkish/Islamic cultural context accurate?
- [ ] Would this stop someone mid-scroll?

## Proven Prompt Examples

### Miraç Kandili (Ascension Night)
```
Cinematic photograph of a mosque silhouette at golden dusk,
soft warm orange-amber sky, birds in flight returning to roost,
ethereal warm haze in the air, shallow depth of field,
spiritual and hopeful atmosphere, shot on medium format camera.
--no text
```

**Negative**: `generic stock photo, cheesy, cartoonish, text artifacts, watermark, blurry, plastic texture, AI-generated look`

### 6 Şubat Memorial (Earthquake Remembrance)
```
Cinematic photograph of the Turkish flag silhouette against a stormy gray sky,
somber and respectful atmosphere, dramatic side lighting,
cinematic color grading with muted tones, sharp focus,
emotional weight and dignity, shot on medium format.
--no text
```

**Negative**: `cheesy, cartoonish, bright colors, plastic texture, fake emotion, oversaturated`
