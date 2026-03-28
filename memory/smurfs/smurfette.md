# Smurfette — Personal Memory

## Role
AI image generation specialist for Wesoco digital agency. Special day visuals for client social media.

## Dispatch Model
`sonnet`

## Wesoco Brand
- Navy: `#0c1727` | Red: `#E84445`
- Logo: `tools/image-generator/base-pics/wesoco-logo-beyaz.svg` (dark bg) / `wesoco-logo-lacivert.svg` (light bg)
- Style reference: `tools/image-generator/sample/`

## Platform Formats
| Format | Dimensions |
|--------|-----------|
| Story (9:16) | 1024×1792 |
| Feed (1:1) | 1024×1024 |
| Banner (16:9) | 1792×1024 |
| OG (1.91:1) | 1200×630 |

## DALL-E Content Filter — Blocked
- Close physical contact: hugging, kissing, forehead touch, hand-holding
- Words: "intimate", "embrace", "couple holding each other", "kiss"
**Workaround:** Object/atmosphere compositions — rose, candle, letter, bokeh lights, sunset

## Proven Prompt Phrases (2026 Editorial)
- `"ultra-fine film grain"`
- `"ethereal warm haze"`
- `"shallow depth of field, silky smooth background blur"`
- `"cinematic color grading, analog warmth, medium format feel"`
- `"not a stock photo, emotionally real"`
- `"shot on medium format camera"`

## Negative Prompt Template (always include)
```
generic stock photo, cheesy, clipart, kitsch, oversaturated, cartoonish,
plastic, AI-generated look, watermark, text, words, letters, blurry subject,
low quality, corporate clipart
```

## Story Format Rule
Leave top 12–25% clean for text overlay:
`"clean dark negative space in upper 25% for text overlay"`

## Bash Pipeline (if dispatch fails)
```bash
cd /Users/ckansiz/workspace/smurfs
tools/image-generator/.venv/bin/python - <<'EOF'
import sys
sys.path.insert(0, 'tools/image-generator')
from smurfs.image_smurf import generate_with_dalle
filepath = generate_with_dalle(
    positive_prompt="...", negative_prompt="...",
    platform="story", overlay_text=""
)
print(filepath)
EOF
```

## Turkish Special Days
Ramazan/Kurban Bayramı, Kandiller, 23 Nisan, 19 Mayıs, 30 Ağustos, 29 Ekim,
10 Kasım, 6 Şubat, 14 Şubat, Anneler/Babalar Günü, Öğretmenler Günü, Yeni Yıl
