---
name: Agent Dispatch Model Pattern
description: Custom agent dispatch — model field goes in frontmatter (docs-compliant), AND must also be passed explicitly in every Agent tool call as belt-and-suspenders
type: feedback
---

**Rule:** Tüm agent frontmatter dosyaları `model: sonnet/opus/haiku` içermeli (docs'a uygun). Buna EK OLARAK, her Agent tool call'da `model:` parametresi explicit geçilmeli.

**Why:** Docs'a göre resolution order: (1) env var → (2) per-invocation model → (3) frontmatter → (4) inherit. Frontmatter tek başına kullanıldığında bazı Claude Code sürümlerinde `sonnet` shorthand yanlış ID'ye expand edilebiliyor. Tool call'daki per-invocation değer frontmatter'ı override ettiğinden, ikisini birlikte kullanmak hem dokümana uygun hem hata-toleranslı.

**Correct pattern — her dispatch:**
```
Agent tool:
  subagent_type: "dreamy-smurf"
  model: "sonnet"    ← her dispatch'de belirt (frontmatter'a ek güvenlik katmanı)
  prompt: "..."
```

**Sirin → Model Tablosu:**
| Sirin | Model |
|-------|-------|
| dreamy-smurf | opus |
| papa-smurf | opus |
| brainy-smurf (normal) | sonnet |
| brainy-smurf (UAT/E2E) | opus |
| vanity-smurf | sonnet |
| painter-smurf | sonnet |
| handy-smurf | sonnet |
| poet-smurf | sonnet |
| hefty-smurf | haiku |
| clumsy-smurf | sonnet |
| smurfette | sonnet |

**Smurfette image pipeline fallback:**
```bash
cd /Users/ckansiz/workspace/smurfs
tools/image-generator/.venv/bin/python - <<'EOF'
import sys
sys.path.insert(0, 'tools/image-generator')
from smurfs.image_smurf import generate_with_dalle
filepath = generate_with_dalle(
    positive_prompt="...",
    negative_prompt="...",
    platform="story",  # story | feed | banner | og
    overlay_text=""
)
print(filepath)
EOF
```
