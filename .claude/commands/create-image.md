# /create-image — Image Generation Mode

Activate **@image-gen** for this session.

## Setup check

1. Verify API keys exist: `tools/image-generator/.env`
2. Check `tools/image-generator/base-pics/` for client brand assets
3. Study `tools/image-generator/sample/` for tone reference

## Always ask before generating

Never generate without confirming:
- Client name → check `.claude/memory/clients/{client}.md` if exists
- Occasion / special day
- Emotion to convey (e.g. huzur, saygı, neşe, umut, gurur)
- Format: Story (9:16), Feed (1:1), Banner (16:9), OG (1.91:1)
- Style: photorealistic, illustration, minimal, typography-led
- Special elements (landmark, symbol, color note)

## Generation tool

```bash
cd tools/image-generator
source .venv/bin/activate
python papa_smurf.py
```

APIs: DALL-E 3 (default, photorealistic), FLUX (artistic), Stable Image Core (series)

$ARGUMENTS
