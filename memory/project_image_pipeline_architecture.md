---
name: Image Generator Pipeline Architecture
description: Technical architecture of tools/image-generator/ - modules, compositing, dependencies, known issues
type: project
---

Pipeline at `tools/image-generator/` generates AI images with automatic text + logo compositing.

## Module Map

| File | Role |
|------|------|
| `papa_smurf.py` | Interactive CLI entry point |
| `config.py` | API keys, format definitions, BRANDING config |
| `smurfs/prompt_smurf.py` | Turkish → English prompt via Claude API (needs ANTHROPIC_API_KEY) |
| `smurfs/image_smurf.py` | DALL-E 3 / FLUX / Stability AI generators |
| `smurfs/compositor_smurf.py` | Post-processing: text overlay + logo compositing via Pillow |

## Compositing Pipeline (compositor_smurf.py)

After image generation, every image automatically goes through `finalize_image()`:
1. `composite_text()` — adds Turkish overlay text to upper area
2. `composite_logo()` — adds Wesoco logo to bottom-center

**Logo auto-selection:** analyses bottom 30% luminance → dark bg = white logo, light bg = navy logo

**Text config (config.py BRANDING):**
- `text_size_ratio`: 0.065 (font = image.width × 0.065)
- `max_chars` formula: `image.width / (font_size × 0.75)` → ~20 chars/line → 2 lines
- Font: Montserrat-Bold.ttf — downloaded on first run to `base-pics/Montserrat-Bold.ttf`
- `text_top_ratio`: 0.12 (text starts at 12% from top)

## System Dependencies

- `cairo` system library required by `cairosvg` (SVG → PNG for logos)
- Install once: `brew install cairo`
- Python packages: `Pillow>=10.0.0`, `cairosvg>=2.7.0` (in requirements.txt)

## Running the Pipeline (Bash pattern)

Always use the image-generator's own venv and add its directory to sys.path:
```bash
cd /Users/ckansiz/workspace/smurfs
tools/image-generator/.venv/bin/python - <<'EOF'
import sys
sys.path.insert(0, 'tools/image-generator')
from dotenv import load_dotenv  # NOT needed - config.py handles it
from smurfs.image_smurf import generate_with_dalle
import os

filepath = generate_with_dalle(
    positive_prompt="...",
    negative_prompt="...",
    platform="story",
    overlay_text="..."
)
print(os.path.abspath(filepath))
EOF
```

**IMPORTANT:** `config.py` uses `load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env"))` — loads `.env` by absolute path, works from any working directory. Do NOT add a separate `load_dotenv()` call in the Bash script.

## API Keys (.env)

- `OPENAI_API_KEY` — DALL-E 3 (currently active)
- `REPLICATE_API_TOKEN` — FLUX 1.1 Pro (not set)
- `STABILITY_API_KEY` — Stability AI (not set)
- `ANTHROPIC_API_KEY` — needed for prompt_smurf.py (not set — prompt_smurf currently unusable)

**How to apply:** When running the pipeline without ANTHROPIC_API_KEY, skip `prompt_smurf` and write the prompt directly. Call `generate_with_dalle(positive_prompt, negative_prompt, platform, overlay_text)` directly.
