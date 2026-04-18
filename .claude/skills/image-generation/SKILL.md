---
name: image-generation
description: This skill should be used when the user asks to "create a special-day visual", "generate a holiday post", "make a Wesoco client image", "create social media image" (story/feed/banner/OG), or invokes /image-generation. Drives DALL-E 3 / FLUX / Stable Image Core via the local Python tool.
version: 1.0.0
---

# Image Generation Workflow (Wesoco Clients)

Apply when generating special-day social media visuals (religious holidays, national days, seasonal occasions) for Wesoco digital agency clients. Owned by **@image-gen**.

## Wesoco Brand

- **Primary**: `#0c1727` (dark navy)
- **Accent**: `#E84445` (vibrant red)
- **Logo files**: `tools/image-generator/base-pics/`
- **Tone**: Professional, modern, Turkish cultural awareness, emotionally precise

## Setup Check (before first generation)

1. Verify API keys exist: `tools/image-generator/.env`
2. Check `tools/image-generator/base-pics/` for client brand assets
3. Study `tools/image-generator/sample/` for tone reference

## Always Ask Before Generating

Never generate without confirming:
1. Which client? (check `.claude/memory/clients/{client}.md` if exists)
2. What occasion / special day?
3. What emotion to convey? (e.g. huzur, saygı, neşe, umut, gurur)
4. Format? Story (9:16), Feed (1:1), Banner (16:9), OG (1.91:1)
5. Style? Photorealistic, illustration, minimal, typography-led
6. Special elements? (landmark, symbol, color preference)

## Prompt Rules

- Always write prompts in **English** (APIs perform better)
- Cinematic approach: mood, lighting, camera angle, depth
- Leave clean space for text overlays
- Avoid generic stock-photo aesthetic
- Study `tools/image-generator/sample/` for tone reference before crafting prompt

## Generation Tool

```bash
cd tools/image-generator
source .venv/bin/activate
python papa_smurf.py
```

APIs:
- **DALL-E 3** — default, best for photorealistic
- **FLUX** — artistic, painterly
- **Stable Image Core** — consistent series

## Quality Check (before delivery)

- [ ] Cinematic, not stock-photo?
- [ ] Clean space for text overlay?
- [ ] Brand colors present?
- [ ] Emotion matches occasion?
- [ ] Turkish/Islamic cultural context accurate?

## Delivery Format

```
### Generated
- File: [path]
- Prompt: [exact prompt used]
- Rationale: [why this approach]
- Variations: [1-2 alternative directions]
```
