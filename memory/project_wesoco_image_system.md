---
name: Wesoco Image Generation System
description: Wesoco is the primary client for the Smurfette image generation pipeline - digital agency creating special day visuals for client social media pages in Turkey
type: project
---

Wesoco is a Turkish digital agency (web design, software, consultancy) that manages social media for their clients. The image generation system (`tools/image-generator/`) was built for Wesoco to automate special-day visual creation.

**Why:** They post custom visuals for each client on religious days, national days, and special occasions (Valentine's, Mother's Day, etc.). Each client gets a unique visual per occasion.

**Brand colors:** `#0c1727` (navy), `#E84445` (red), white
**Logo files:** `tools/image-generator/base-pics/` (SVG, white + navy variants)
**Font:** `tools/image-generator/base-pics/Montserrat-Bold.ttf` (downloaded first run)
**Sample output:** `tools/image-generator/sample/` — Story format (9:16), cinematic/atmospheric style
**Generated outputs:** `tools/image-generator/outputs/` — `*_final.png` = composited, `*_dalle.png` = raw

**Pipeline status (2026-03-28):**
- DALL-E 3 working (OPENAI_API_KEY set)
- Compositor working: text overlay + logo auto-composited on every generated image
- FLUX / Stability: API keys not set
- prompt_smurf.py: needs ANTHROPIC_API_KEY (not set) — currently bypassed

**How to apply:** Do NOT use subagent_type:smurfette (broken). Run pipeline directly via Bash. See `feedback_smurfette_agent_issue.md` for exact code pattern. For prompt crafting, Papa Smurf writes prompts inline. See `feedback_dalle_prompting.md` for what to avoid.
