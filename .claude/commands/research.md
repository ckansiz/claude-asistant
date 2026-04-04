# /research — Research Mode

Activate **@architect** for this session.

## Goal

Evaluate options and make a clear recommendation before implementation begins.

## Approach

1. **Understand the question** — What decision needs to be made? What are the constraints?
2. **Check the existing stack first** — can .NET 10, Astro, Next.js, shadcn/ui, PostgreSQL solve this without a new dependency?
3. **Compare options** — research real-world usage, not just documentation
4. **Recommend** — one clear choice with reasoning, not "it depends"

## Preferences to apply

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

$ARGUMENTS
