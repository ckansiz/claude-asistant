---
name: DALL-E 3 Prompting Patterns for Wesoco
description: What works and what gets blocked by DALL-E 3 content filters for social media visuals
type: feedback
---

**Rule:** Never use intimate/physical human interaction in DALL-E 3 prompts. Use object/botanical compositions instead.

**Why:** DALL-E 3 content filters block prompts describing people in close physical contact (e.g., "two people with foreheads touching", "hands intertwined", "intimate embrace") — returns 400 content_policy_violation. This happened on the 14 Şubat request.

**How to apply:** For romantic/emotional occasions, use:
- Single hero object: rose, candle, letter, ring, jewelry
- Atmospheric scenes: bokeh lights, petals scattered, candlelight
- Abstract: color gradients, light rays, sparkles
- Landscapes: sunset, starry sky, city lights at night

Avoid in prompts: "intimate", "embrace", "couple", "holding each other", "forehead touching", "kiss" — all trigger filters.

---

**Rule:** Always end prompt with explicit style anti-keywords.

**Why:** Without negative guidance, DALL-E tends toward stock-photo aesthetics.

**How to apply:** Always append to negative_prompt: `generic stock photo, cheesy, clipart, heart clipart, kitsch, oversaturated, cartoonish, plastic, AI-generated look`

---

**Rule:** For 2026 editorial aesthetic, use these prompt phrases:
- "ultra-fine film grain"
- "ethereal warm haze"
- "shallow depth of field, silky smooth background blur"
- "cinematic color grading, analog warmth, medium format feel"
- "shot on medium format camera"
- "not a stock photo, emotionally real"
