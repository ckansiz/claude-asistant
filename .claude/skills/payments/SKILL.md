---
name: payments
description: This skill should be used when the user asks to "add Stripe checkout", "integrate iyzico", "process a payment", "handle webhooks", "set up subscriptions", "add PayTR", or builds any payment flow. Never touch raw card data — always use hosted checkout or tokenization.
version: 1.0.0
---

# Payments Standards (Stripe + iyzico + PayTR)

Apply when integrating payments. Golden rule: **never touch raw card data**. Use hosted checkout (Stripe Checkout, iyzico Inline Pay) or tokenized elements.

## When to Pick What

| Market | Use case | Pick |
|--------|----------|------|
| International | SaaS, subscriptions, digital goods | Stripe |
| Turkey | E-commerce, one-time card payments | iyzico |
| Turkey | Lowest fees, taksit (installments) | PayTR |
| Turkey + KVKK + taksit | Marketplaces, complex flows | iyzico |

Many qoommerce / wcard-website style projects use iyzico + Stripe in parallel (TRY via iyzico, USD/EUR via Stripe).

## PCI Compliance — The Non-Negotiable Rule

- Never POST card numbers to your own server.
- Never log request bodies that might contain card fields.
- Use `Stripe.js` / `iyzico checkout form` / `PayTR iframe` so cards go directly from browser → provider.
- If audited, you want SAQ-A (simplest, minimal responsibility), not SAQ-D.

## Stripe — Checkout Session (one-time)

```ts
// app/api/checkout/route.ts
import Stripe from 'stripe'
import { NextRequest, NextResponse } from 'next/server'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2024-12-18.acacia' })

export async function POST(req: NextRequest) {
  const { priceId, customerId } = await req.json()

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    line_items: [{ price: priceId, quantity: 1 }],
    customer: customerId,
    success_url: `${process.env.NEXT_PUBLIC_URL}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/checkout/cancel`,
    metadata: { orderId: 'internal-order-id' },
  })

  return NextResponse.json({ url: session.url })
}
```

## Stripe — Webhook (source of truth)

Never trust the success redirect alone — the user might close the tab. The webhook is the canonical completion signal.

```ts
// app/api/webhooks/stripe/route.ts
import Stripe from 'stripe'
import { NextRequest, NextResponse } from 'next/server'
import { headers } from 'next/headers'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(req: NextRequest) {
  const body = await req.text()
  const sig = (await headers()).get('stripe-signature')!

  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(body, sig, process.env.STRIPE_WEBHOOK_SECRET!)
  } catch (err) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 })
  }

  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object as Stripe.Checkout.Session
      await markOrderPaid(session.metadata?.orderId, session.payment_intent as string)
      break
    case 'charge.refunded':
      // handle refund
      break
  }

  return NextResponse.json({ received: true })
}

export const runtime = 'nodejs'  // webhook needs raw body
```

### Local webhook testing

```bash
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

## iyzico — Inline Checkout Form

```ts
// npm install iyzipay
import Iyzipay from 'iyzipay'

const iyzipay = new Iyzipay({
  apiKey: process.env.IYZICO_API_KEY!,
  secretKey: process.env.IYZICO_SECRET_KEY!,
  uri: process.env.IYZICO_URI!,  // https://sandbox-api.iyzipay.com (test) / https://api.iyzipay.com (live)
})

export async function createCheckoutForm(order: Order) {
  return new Promise((resolve, reject) => {
    iyzipay.checkoutFormInitialize.create({
      locale: 'tr',
      conversationId: order.id,
      price: order.subtotal.toString(),
      paidPrice: order.total.toString(),
      currency: 'TRY',
      basketId: order.id,
      paymentGroup: 'PRODUCT',
      callbackUrl: `${process.env.APP_URL}/api/payment/iyzico/callback`,
      buyer: {
        id: order.buyer.id,
        name: order.buyer.firstName,
        surname: order.buyer.lastName,
        email: order.buyer.email,
        identityNumber: order.buyer.tckn,   // TCKN required by iyzico
        registrationAddress: order.buyer.address,
        city: order.buyer.city,
        country: 'Turkey',
        ip: order.buyer.ip,
      },
      shippingAddress: {/* ... */},
      billingAddress: {/* ... */},
      basketItems: order.items.map(i => ({
        id: i.id,
        name: i.name,
        category1: i.category,
        itemType: 'PHYSICAL',
        price: i.price.toString(),
      })),
    }, (err: Error, result: { paymentPageUrl: string; token: string }) => {
      if (err) reject(err)
      else resolve(result)
    })
  })
}
```

Redirect user to `result.paymentPageUrl` or embed via iyzico's JS snippet. On callback, verify with `iyzipay.checkoutForm.retrieve` using the token — never trust the callback body alone.

## Webhook Idempotency

Webhooks retry. Handle the same event twice without double-charging or double-shipping:

```ts
// Use Stripe event.id or iyzico conversationId as idempotency key
const existing = await db.webhookEvent.findUnique({ where: { providerId: event.id } })
if (existing) return NextResponse.json({ received: true })

await db.$transaction([
  db.webhookEvent.create({ data: { providerId: event.id } }),
  db.order.update({ where: { id: orderId }, data: { status: 'PAID' } }),
])
```

## Test vs Live

- Separate API keys per environment — never mix
- Stripe: `sk_test_...` vs `sk_live_...`
- iyzico: `sandbox-api.iyzipay.com` vs `api.iyzipay.com`
- Block the live keys from committing: add pre-commit check or use secret scanner
- Smoke test after every deploy: 1 TL test charge, confirm webhook fires, refund it

## Refunds

Build a refund UI from day one — support asks for it on day two. Always require a reason field, log who triggered it, send the customer an automated email.

## KVKK / Compliance Notes

- iyzico stores card tokens — you only store the token reference, never the number
- Order + customer data stored in your DB is PII → backups encrypted, access logged
- For EU customers, add explicit GDPR consent before checkout
- Invoice (e-Arşiv / e-Fatura) integration via Logo, Paraşüt, or similar — out of scope for this skill

## Error Handling

- Network errors on webhook → return 500, Stripe/iyzico will retry
- Business errors (already paid, invalid state) → return 200 + log, don't make them retry forever
- Always show user a branded error page, never raw provider errors

## Companion Skills

- `security` — secret management, webhook signatures
- `database` — order + payment schema, idempotency tables
- `forms` — checkout forms with KVKK consent
