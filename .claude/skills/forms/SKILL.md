---
name: forms
description: This skill should be used when the user asks to "add a contact form", "build a form", "validate form input", "add spam protection", "send form email", "integrate Resend/Postmark/Brevo", "add Cloudflare Turnstile", or handles form submissions in Astro / Next.js projects.
version: 1.0.0
---

# Forms Standards (Contact, Signup, Lead Capture)

Apply for any form handling in Astro / Next.js projects. Forms are the #1 feature on marketing sites — get this right.

## Core Rules

- Client-side validation is UX; server-side validation is security. Always do both.
- Never email raw user input without HTML escaping.
- Always rate-limit form endpoints.
- Never commit SMTP / email API keys.

## Stack Choices

| Concern | Pick |
|---------|------|
| Validation | Zod (TS) — same schema front + back |
| Spam | Cloudflare Turnstile (free, KVKK-friendly) |
| Email delivery | Resend (default), Postmark, Brevo (TR bulk) |
| Rate limit | Upstash Redis (free tier) or in-memory for single-instance |

## Zod Schema — Single Source of Truth

```ts
// lib/validations/contact.ts
import { z } from 'zod'

export const contactSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  phone: z.string().regex(/^(\+90|0)?5\d{9}$/).optional(),  // TR mobile
  message: z.string().min(10).max(2000),
  kvkkConsent: z.literal(true, { errorMap: () => ({ message: 'KVKK onayı zorunlu' }) }),
})

export type ContactInput = z.infer<typeof contactSchema>
```

Use the same schema in the client component (via `react-hook-form` + `@hookform/resolvers/zod`) and in the API route.

## Next.js — Route Handler

```ts
// app/api/contact/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { Resend } from 'resend'
import { contactSchema } from '@/lib/validations/contact'
import { verifyTurnstile } from '@/lib/turnstile'
import { rateLimit } from '@/lib/rate-limit'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function POST(req: NextRequest) {
  const ip = req.headers.get('x-forwarded-for') ?? 'unknown'
  const { success } = await rateLimit.limit(ip)
  if (!success) return NextResponse.json({ error: 'Too many requests' }, { status: 429 })

  const body = await req.json()
  const parsed = contactSchema.safeParse(body)
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 })
  }

  const turnstileOk = await verifyTurnstile(body.turnstileToken, ip)
  if (!turnstileOk) return NextResponse.json({ error: 'Bot detected' }, { status: 403 })

  const { name, email, message } = parsed.data
  await resend.emails.send({
    from: 'Website <noreply@client-domain.com>',
    to: 'info@client-domain.com',
    replyTo: email,
    subject: `Yeni iletişim: ${name}`,
    text: `${message}\n\n— ${name} (${email})`,
  })

  return NextResponse.json({ ok: true }, { status: 201 })
}
```

## Astro — API Route

```ts
// src/pages/api/contact.ts
import type { APIRoute } from 'astro'
import { Resend } from 'resend'
import { contactSchema } from '@/lib/validations/contact'

const resend = new Resend(import.meta.env.RESEND_API_KEY)

export const POST: APIRoute = async ({ request, clientAddress }) => {
  const body = await request.json()
  const parsed = contactSchema.safeParse(body)
  if (!parsed.success) {
    return new Response(JSON.stringify({ error: parsed.error.flatten() }), { status: 400 })
  }

  await resend.emails.send({
    from: 'Website <noreply@client-domain.com>',
    to: 'info@client-domain.com',
    replyTo: parsed.data.email,
    subject: `Yeni iletişim: ${parsed.data.name}`,
    text: parsed.data.message,
  })

  return new Response(JSON.stringify({ ok: true }), { status: 201 })
}
```

## Spam Protection — Cloudflare Turnstile

Free, privacy-respecting, no user-facing puzzle 99% of the time.

```tsx
// Client
<div className="cf-turnstile" data-sitekey={process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY} />
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer />
```

```ts
// Server — lib/turnstile.ts
export async function verifyTurnstile(token: string, ip: string): Promise<boolean> {
  const res = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      secret: process.env.TURNSTILE_SECRET_KEY!,
      response: token,
      remoteip: ip,
    }),
  })
  const data = await res.json()
  return data.success === true
}
```

Honeypot field — second line of defense:

```tsx
<input name="website" type="text" tabIndex={-1} autoComplete="off" className="hidden" aria-hidden="true" />
// Server: if body.website is non-empty → reject silently
```

## Rate Limiting (Upstash)

```ts
// lib/rate-limit.ts
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

export const rateLimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(5, '1 m'),  // 5 submissions per minute per IP
  analytics: true,
})
```

## Email Delivery

**Resend** (default): great DX, TypeScript-first, from custom domain (verify SPF/DKIM/DMARC at Cloudflare DNS).

**Postmark**: higher deliverability for transactional, slightly older API.

**Brevo** (ex-Sendinblue): TR-friendly pricing for clients that also want newsletter sends from same tool.

Deliverability setup — one-time per domain:
1. Add sending domain in Resend dashboard
2. Copy DNS records → Cloudflare DNS
3. Wait for verification (15 min)
4. Send test from `noreply@client-domain.com` to personal inbox, check spam folder

## Success UX

- Optimistic state: button disables, shows "Gönderiliyor..."
- Success: inline toast + form reset, not a page redirect
- Error: show the field-level error from Zod next to the offending input
- Never show raw 500 errors — log them server-side, show "Bir hata oluştu, lütfen tekrar deneyin"

## KVKK Checkbox

TR clients need explicit KVKK consent for contact forms that store PII:

```tsx
<label>
  <input type="checkbox" {...register('kvkkConsent')} />
  <span>
    <a href="/kvkk" target="_blank">KVKK Aydınlatma Metni</a>'ni okudum, onaylıyorum.
  </span>
</label>
```

Link to a `/kvkk` page with actual text — template from client's lawyer, never from AI.

## Companion Skills

- `typescript` — Zod schemas, types
- `security` — CSRF, CORS, rate limiting
- `nextjs` / `astro` — route handler patterns
