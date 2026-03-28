---
name: Smurfette Agent Model Issue
description: subagent_type smurfette fails to launch - workaround is to run pipeline directly via Bash
type: feedback
---

**Rule:** Do NOT dispatch `subagent_type: smurfette` — it fails immediately with a model error. Run the image generator pipeline directly with Bash instead.

**Why:** The smurfette agent (`.claude/agents/smurfette.md`) uses `model: claude-sonnet-4.6` matching all other agents, but the Agent tool cannot instantiate it. Error: "There's an issue with the selected model (claude-sonnet-4.6). It may not exist or you may not have access to it." Tried multiple times, always fails.

**How to apply:** When the user asks for image generation (any occasion, any client), skip the Smurfette agent dispatch entirely. Instead:

1. Craft the prompt directly (Papa Smurf writes it inline)
2. Run via Bash:
```bash
cd /Users/ckansiz/workspace/smurfs/tools/image-generator
.venv/bin/python - <<'EOF'
import sys, os
sys.path.insert(0, '.')
from dotenv import load_dotenv
load_dotenv('.env')
from smurfs.image_smurf import generate_with_dalle

filepath = generate_with_dalle(
    positive_prompt="...",
    negative_prompt="...",
    platform="story",  # or "feed", "banner", "og"
    overlay_text="..."  # Turkish text to overlay, or "" for logo-only
)
print(os.path.abspath(filepath))
EOF
```
3. Read the output file to show the user the result
