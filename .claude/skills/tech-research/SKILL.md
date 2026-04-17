---
name: tech-research
description: This skill should be used when the user asks to "research a library", "compare frameworks", "evaluate options", "pick a tool", "should we use X or Y", or invokes /research. Produces a clear recommendation with trade-offs (handed to @architect).
version: 1.0.0
---

# Tech Research Workflow

Apply when evaluating libraries, frameworks, or approaches before implementation begins. Owned by **@architect** (read-only on production code).

## Goal

Evaluate options and produce one clear recommendation — not "it depends".

## Approach

1. **Understand the question** — What decision needs to be made? What are the constraints?
2. **Check the existing stack first** — Can .NET 10, Astro, Next.js, shadcn/ui, PostgreSQL solve this without a new dependency?
3. **Compare options** — Research real-world usage, not just documentation
4. **Recommend** — One clear choice with reasoning

## Preferences to Apply

- Prefer battle-tested over cutting-edge for production
- Prefer libraries already in the workspace (avoid adding new ones unnecessarily)
- Note license (MIT/Apache preferred) and maintenance status
- Include concrete examples, not just theory

## Output Format

```
### Topic: {topic}

### Recommendation
{clear choice + reasoning — 2-3 paragraphs}

### Trade-offs
| Option | Pros | Cons | Fit (High/Med/Low) |

### Implementation notes
{key things to know when implementing the recommendation}

### Sources
```
