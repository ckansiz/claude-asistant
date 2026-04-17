---
name: client-handoff
description: This skill should be used when the user asks to "onboard a new client", "kick off a project", "prepare a client intake", "deliver a project", "do handoff", "transfer credentials", "write a client status update", or sets up a new entry under `.claude/memory/clients/`.
version: 1.0.0
---

# Client Intake, Kickoff & Handoff Workflow

Apply for the non-technical side of freelance work: capturing scope, running kickoff, sending status updates, and delivering the finished project.

## 1. Intake (before any code)

Capture in `.claude/memory/clients/{slug}.md`:

```markdown
# {Client Name}

## Contact
- Primary: {name, role, email, phone}
- Decision maker: {name} (if different)
- Billing: {name, company, VKN/TCKN, address}

## Scope
- Goal: {one sentence — what success looks like}
- Must-have: {bullet list}
- Nice-to-have: {bullet list}
- Out of scope: {explicit exclusions}

## Constraints
- Budget: {range or fixed}
- Timeline: {target launch date}
- Tech preferences / existing vendors
- Legal: KVKK considerations, data residency

## Tone / Brand
- Voice: {formal/casual, TR/EN}
- Colors, font, logo files location
- Reference sites they like

## Access
- GitHub org / repo: {url}
- Hosting: {Vercel/Fly/Hetzner}
- Domain registrar: {where DNS lives}
- Shared vault: {1Password / Bitwarden vault name}
```

For deep requirements + tech spec, delegate to `spec-writing` skill.

## 2. Kickoff

Agenda (30–45 min call):
1. Confirm goal + success metrics
2. Walk through scope doc — lock must-haves
3. Milestones + approximate dates
4. Communication cadence (weekly / daily, async / call)
5. Tooling (Slack / WhatsApp / email, GitHub for issues)
6. Payment terms (50% up front, 50% on delivery is the default for fixed-scope)

Output: signed SOW (or email confirmation for small jobs) + `docs/project-brief.md` committed to repo.

## 3. Status Updates

Weekly async update template:

```
### Week of {date} — {project}

Done this week
- {bullet}

Next week
- {bullet}

Blocked / needs from you
- {bullet — be specific, include deadline}

Demo
- Preview URL: {vercel / fly preview link}
```

Send even when nothing happened — silence reads as trouble.

## 4. Change Requests

Any scope change → written confirmation before implementing. Template:

```
Request: {what they asked}
Impact: {+X days, +Y TL / €, affects {Z} milestone}
Decision needed by: {date}
```

Log accepted changes in `docs/change-log.md`.

## 5. Delivery / Handoff

Handoff checklist:

- [ ] All acceptance criteria met (see `docs/requirements.md`)
- [ ] Production deploy verified — smoke test critical paths
- [ ] Env vars, secrets, domains transferred to client's account (or documented if staying under my account)
- [ ] `README.md` with: stack, local setup, deploy command, env var list, contact info
- [ ] `docs/runbook.md` — how to do common tasks (add a page, update content, rotate a secret)
- [ ] Short video walkthrough (Loom / Tella) — 5-10 min, covers CMS/admin usage
- [ ] Final invoice sent
- [ ] GitHub repo access handed over (or kept under my org per contract)
- [ ] Post-launch support window defined (e.g. 14 days free bugfixes, billable after)

## 6. Post-Launch

- Day 1, day 7, day 30 check-ins — catch regressions before they escalate
- Archive client folder if no ongoing retainer: move to `~/workspace/wesoco/works/_archive/{slug}/`
- Keep `.claude/memory/clients/{slug}.md` regardless — institutional memory

## Companion Skills

- `spec-writing` — for formal requirements + tech spec docs
- `deployment` — production deploy & DNS transfer
- `seo` — pre-launch SEO audit
- `performance` — pre-launch Lighthouse pass
