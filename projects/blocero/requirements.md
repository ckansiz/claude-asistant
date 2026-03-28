# Blocero — Requirements & Specification

> **Akıllı Site Yönetimi — Tek Platformda**
> Version: 1.0 | Status: Pre-Development | Confidential

---

## 1. Product Overview

### Elevator Pitch
Blocero is Turkey's first all-in-one apartment/site management ecosystem. While competitors offer basic dues tracking and announcements, Blocero adds financial management, a hyperlocal advertising network, a craftsman marketplace, taxi service, doorman management, bill automation, and first-party data advertising — all under one roof.

### Problem Statement
Turkey has ~10 million apartment units managed by volunteer site managers using WhatsApp groups, spreadsheets, and paper. Existing software only solves the dues problem. No platform connects residents, managers, craftsmen, drivers, and doormen in a single verifiable data ecosystem that can also monetize through advertising.

### Unique Positioning
| Dimension | Competitors | Blocero |
|-----------|-------------|---------|
| Revenue model | SaaS subscription | Freemium + ads + commissions |
| Ad targeting | None | Hyperlocal (neighborhood/site level) |
| Data quality | None | First-party: verified household income, lifestyle |
| Doorman management | None | Full task/attendance/performance tracking |
| Service marketplace | None | Craftsman + taxi + transfer |
| Switching cost | Low | High (dues history, decisions, resident data locked in) |

---

## 2. User Personas

### 2.1 Super Admin (Platform Owner)
- **Access:** Web only
- **Goals:** Monitor all sites, manage modules, approve ads, view revenue reports
- **Key actions:** Toggle modules via API key, approve ad campaigns, view platform KPIs

### 2.2 Site Manager (Yönetici)
- **Access:** Web + Mobile
- **Profile:** Volunteer apartment manager, 35-60 years old, non-technical
- **Pain points:** Collecting dues via WhatsApp, keeping manual expense records, organizing meetings
- **Goals:** Automate dues, be transparent with residents, reduce administrative burden
- **Key actions:** Add residents, record expenses, send announcements, create polls, assign fault repairs

### 2.3 Resident (Sakin)
- **Access:** Mobile only
- **Profile:** Apartment dweller, 25-65 years old
- **Pain points:** Not knowing where dues money goes, chasing craftsmen, no visibility into building decisions
- **Goals:** Pay dues easily, see expense transparency, request services, participate in governance
- **Key actions:** Pay dues, view expense reports, vote, request craftsman/taxi, receive notifications

### 2.4 Craftsman (Usta)
- **Access:** Mobile only
- **Profile:** Self-employed service provider, district-based
- **Pain points:** Finding customers, unpredictable income, no digital presence
- **Goals:** Consistent job flow, fair pricing, verified reputation
- **Key actions:** Register with categories, receive job requests, submit quotes, complete jobs, collect payment

### 2.5 Driver (Şoför)
- **Access:** Mobile only
- **Profile:** Local driver, district-based, verified
- **Goals:** Steady ride income from trusted residents
- **Key actions:** Register with vehicle, receive ride requests, complete rides, collect payment

### 2.6 Doorman (Kapıcı)
- **Access:** Mobile only
- **Profile:** Building employee, 30-55 years old, basic smartphone user
- **Pain points:** No digital task tracking, disputes about attendance/performance
- **Goals:** Clear task list, prove work done, manage packages
- **Key actions:** Log entry time, complete task checklist, log garbage/cleaning steps, accept packages

### 2.7 Advertiser (Reklam Veren)
- **Access:** Web (ads.blocero)
- **Profile:** Local business or national brand
- **Goals:** Hyper-targeted local advertising superior to Meta/Google
- **Key actions:** Create campaign, select geography on map, set budget, upload creative, monitor performance

### 2.8 B2B Construction Firm
- **Access:** Web
- **Profile:** Real estate developer with multiple completed projects
- **Goals:** Onboard all apartments at once, provide management solution to buyers
- **Key actions:** Bulk upload apartments via Excel, send resident invitations, manage all projects

---

## 3. User Stories (Faz 1 Priority)

### Site Manager
- As a site manager, I can add residents with their apartment info so I can track who owes what
- As a site manager, I can set monthly dues amounts and due dates so residents are automatically notified
- As a site manager, I can record expenses with receipts so residents can see where their money goes
- As a site manager, I can create announcements with categories and pin important ones
- As a site manager, I can open a poll and automatically announce the result when voting closes
- As a site manager, I can see which residents have paid and send reminders to those who haven't

### Resident
- As a resident, I can pay my monthly dues via credit card through the app
- As a resident, I can see the monthly expense report and receipt photos
- As a resident, I can vote on active polls from my phone
- As a resident, I can request a craftsman from the catalog and track the repair status
- As a resident, I can receive package arrival notifications from the doorman

### Doorman
- As a doorman, my app login counts as clocking in so my attendance is tracked automatically
- As a doorman, I can log the 3-step garbage process and residents are notified
- As a doorman, I can log package arrivals and notify the resident immediately
- As a doorman, I can see my daily task checklist and mark items complete

### Craftsman (Faz 1 basic)
- As a craftsman, I can register with my categories and district
- As a craftsman, I can receive job requests and accept or decline
- As a craftsman, I can submit a quote for bid-based jobs

---

## 4. Feature List

### Module: Financial Management
| Feature | Priority | Faz |
|---------|----------|-----|
| Resident dues setup (amount, date, frequency) | P0 | 1 |
| Dues payment via iyzico (credit card) | P0 | 1 |
| Late fee calculation | P0 | 1 |
| Payment history per resident | P0 | 1 |
| Push notification reminders (unpaid) | P0 | 1 |
| Expense entry with categories + receipt photo | P0 | 1 |
| Monthly expense report (resident-visible) | P0 | 1 |
| Bank account auto-matching | P1 | 2 |
| Budget vs actual chart | P1 | 1 |
| PDF export (accounting report) | P1 | 1 |
| Bulk bill payment (BDDK required) | P2 | 2 |

### Module: Governance
| Feature | Priority | Faz |
|---------|----------|-----|
| Announcement system (categories, pin, archive) | P0 | 1 |
| Read receipt tracking | P0 | 1 |
| Simple poll / voting | P0 | 1 |
| Auto-announce poll result | P0 | 1 |
| Decision book (numbered, PDF, visibility toggle) | P1 | 1 |
| Meeting management (agenda, minutes, digital signature) | P1 | 1 |
| Fault reporting (resident → manager) | P1 | 1 |
| Fault → craftsman assignment | P1 | 1 |
| Maintenance calendar (elevator, generator, fire ext.) | P2 | 2 |

### Module: Doorman Management (unique differentiator)
| Feature | Priority | Faz |
|---------|----------|-----|
| Entry time tracking (login = clock-in) | P0 | 1 |
| Garbage 3-step logging | P0 | 1 |
| Package receipt + resident notification | P0 | 1 |
| Daily task checklist (cleaning, stairs, elevator, parking) | P0 | 1 |
| Absence reporting | P1 | 1 |
| Monthly performance report | P1 | 1 |
| Resident request to doorman | P2 | 2 |
| Payroll integration | P3 | 3 |

### Module: Craftsman Marketplace
| Feature | Priority | Faz |
|---------|----------|-----|
| Craftsman registration + district selection | P0 | 2 |
| Fixed price catalog (standard jobs) | P0 | 2 |
| Job request (resident → craftsman) | P0 | 2 |
| Bid-based large jobs | P1 | 2 |
| Rating system | P1 | 2 |
| Neighboring district auto-expansion (24h no bid) | P2 | 2 |
| iyzico payment + 5% commission deduction | P0 | 2 |

### Module: Taxi & Transfer
| Feature | Priority | Faz |
|---------|----------|-----|
| Driver registration + district | P0 | 2 |
| Instant ride request | P0 | 2 |
| iyzico payment + 5% commission | P0 | 2 |
| Fixed routes (hospital, school, mall) | P1 | 2 |
| Elderly subscription service | P2 | 3 |

### Module: Advertising (ads.blocero)
| Feature | Priority | Faz |
|---------|----------|-----|
| Self-serve advertiser panel | P0 | 2 |
| Geographic targeting (il→ilçe→mahalle→site map) | P0 | 2 |
| Home screen banner (CPC) | P0 | 2 |
| Push notification ad (CPC) | P1 | 2 |
| Service interstitial sponsor card (CPC) | P1 | 2 |
| Post-payment full-screen ad (CPC) | P1 | 2 |
| Native sponsored announcement (CPM) | P1 | 2 |
| Super admin ad approval workflow | P0 | 2 |
| Live performance reporting | P0 | 2 |
| Birthday ad personalization | P2 | 3 |
| Physical digital signage | P3 | 3 |

### Surface: Marketing Site
| Feature | Priority | Faz |
|---------|----------|-----|
| Landing page (hero, features, demo CTA) | P0 | 1 |
| Pricing page | P0 | 1 |
| Demo site (live walkthroughs per user type) | P1 | 1 |
| Blog (TR initially, 5 languages Faz 3) | P1 | 2 |
| Auto-generated city pages (81 il × services) | P1 | 2 |
| llms.txt (AI engine optimization) | P2 | 2 |

---

## 5. Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Mobile | React Native (Expo managed) | Single codebase, Android + iOS, fastest iteration for Faz 1 |
| Web Frontend | Next.js 15 + TypeScript | SSR mandatory for SEO city pages, App Router |
| Styling | Tailwind CSS + shadcn/ui | Consistent design system, fast development |
| Backend | NestJS (Node.js) | TypeScript end-to-end, good microservice support, large ecosystem |
| Database | PostgreSQL | Relational data model fits well (residents, dues, apartments) |
| Cache | Redis | Session management, real-time presence, rate limiting |
| Media Storage | Cloudflare R2 | Cost-effective, global CDN, S3-compatible |
| Push Notifications | Firebase Cloud Messaging | Android + iOS unified |
| SMS | Netgsm (TR primary) + Twilio (international) | Netgsm cheaper for Turkish numbers |
| Payment | iyzico | Turkish market standard, good documentation |
| Maps | Google Maps SDK | Required for ads geographic targeting |
| Real-time | Socket.io (WebSocket) | Chat, live location, instant notifications |

### Architecture Decision: Faz 1
**Start modular monolith, not full microservices.** Reason: 50-site pilot does not justify microservice operational overhead. Design with clear module boundaries (separate NestJS modules) so extraction to microservices is straightforward at Faz 2-3 scale.

---

## 6. Design System

| Property | Value |
|----------|-------|
| Font | DM Sans — 400 regular, 500 medium, 700 bold |
| Primary color | `#1B2B5E` — Navy (trust, technology) |
| Accent color | `#E32B2B` — Red (action, energy, CTAs) |
| Background | `#F8F9FC` — Very light gray-white |
| Card | `#FFFFFF`, `0.5px border`, `12px radius` |
| Corner style | Rounded — `10-12px border-radius` |
| Theme | Light (dark mode optional, Faz 2) |
| Logo | "B" + block grid icon, navy + red |
| Design language | Modern & minimal (Airbnb / Notion) |
| Icon set | Lucide Icons (consistent stroke width) |
| Sidebar | `#1B2B5E` background, white text |
| Primary button | `#1B2B5E` fill, white text |
| Secondary button | White fill, `#1B2B5E` border & text |
| Danger button | `#E32B2B` fill, white text |

### UI Component Library

**shadcn/ui + Tailwind CSS** — default for all web surfaces (Next.js marketing site + yönetici paneli).

- shadcn/ui component primitives (Button, Card, Badge, Table, Dialog, Sheet, etc.)
- Tailwind CSS for layout, spacing, responsive design
- Custom Blocero theme token overrides in `tailwind.config.ts` (navy, red, radius)
- Lucide React icon set (already bundled with shadcn)
- React Native paper veya NativeBase mobil için (Faz 1 kararı: Expo ile birlikte değerlendirile)

> **Kural:** Aksi belirtilmedikçe tüm UI işleri shadcn/ui + Tailwind ile yapılır. Custom CSS sadece shadcn'ın kapsayamadığı özel bileşenler için.

### Design Alternatifleri (Referans)

| Dosya | Yüzey | Yön |
|-------|-------|-----|
| `designs/design-a.html` | Marketing landing page | Minimal, content-first — Linear/Notion tarzı |
| `designs/design-b.html` | Marketing landing page | Bold, dark hero, feature-showcase — Vercel/Stripe tarzı |
| `designs/design-admin.html` | Yönetici dashboard | Referans panel tasarımı |

---

## 7. Revenue Model

| Stream | Mechanism | Commission | When Active |
|--------|-----------|------------|-------------|
| Ads (CPC/CPM) | ads.blocero self-serve | Advertiser pays per click/impression | Faz 2 |
| Credit card commission | iyzico pass-through | 1-2% per transaction | Faz 1 |
| Craftsman commission | Deducted at payment | 5% per job | Faz 2 |
| Taxi commission | Deducted at payment | 5% per ride | Faz 2 |
| Bill payment commission | Via BDDK license | 1-2% per bill | Faz 2+ |
| Marketplace | 2nd-hand & bulk buy | 3% per transaction | Faz 3 |
| Subscription | Optional manager plan | 20 TL+VAT/month | Faz 1 (optional) |

**Freemium core:** Site managers sign up free, residents adopt organically, ad system creates revenue without charging users.

---

## 8. Launch Roadmap

### Faz 1 — Trabzon Pilot
**Target:** 50 sites, 1,000 DAU
**Duration:** ~6 months
**Open modules:** Dues, expenses, announcements, chat, doorman management, governance (voting, decision book)
**Goal:** Prove product-market fit. Collect first-party data. Zero churn.

### Faz 2 — Karadeniz Region
**Target:** All Trabzon districts + Rize, Giresun, B2B construction firms
**Open additions:** Craftsman marketplace, taxi, ads.blocero launch, bank integration
**Revenue target:** 10,000 TL/month ad revenue

### Faz 3 — Turkey National
**Target:** 10,000 sites, 500,000 DAU
**Open additions:** All modules, national ad campaigns, 81 il city pages live
**Revenue target:** 5,000,000 TL/month ad revenue

### Faz 4 — Global
**Target:** AR, RU, KA markets (Antalya, Alanya, Georgian community)
**Open additions:** Full 5-language support, bill automation (BDDK), white-label option

---

## 9. KPIs

| Metric | Faz 1 Target | Faz 3 Target |
|--------|-------------|-------------|
| Registered sites | 50 | 10,000 |
| Daily Active Users | 1,000 | 500,000 |
| Monthly transaction volume | 500,000 TL | 100,000,000 TL |
| Active ad campaigns | — | 5,000 |
| Monthly ad revenue | — | 5,000,000 TL |
| Registered craftsmen | — | 50,000 |
| App Store rating | 4.5+ | 4.7+ |
| Monthly organic traffic | 5,000 | 1,000,000 |

---

## 10. Open Questions (for Research / Architecture Decision)

| # | Question | Owner | Priority |
|---|----------|-------|----------|
| 1 | Monolith vs microservices for Faz 1 pilot? | Tech lead | High |
| 2 | Expo managed vs bare React Native workflow? | Mobile dev | High |
| 3 | BDDK license — timeline, cost, can Faz 2 launch without it? | Legal | High |
| 4 | iyzico sub-merchant model for craftsman payouts — is it supported? | Tech lead | High |
| 5 | Real-time chat: Socket.io vs third-party (Stream, Sendbird)? | Tech lead | Medium |
| 6 | Hosting: Vercel + Railway vs dedicated Turkish cloud? | DevOps | Medium |
| 7 | KVKK: do we need a DPO (Data Protection Officer) from day 1? | Legal | Medium |
| 8 | Ads targeting algorithm: build in-house or integrate DSP? | Product | Low |
| 9 | White-label offering for B2B — Faz 2 or Faz 3? | Product | Low |
| 10 | Physical digital signage hardware partnership — which vendor? | Business | Low |

---

## 11. Yapılacaklar — Faz 1 TODO List

### 🏗️ Infrastructure & DevOps
- [ ] Domain registration: blocero.com, blocero.com.tr, ads.blocero
- [ ] GitHub repo structure (monorepo: apps/web, apps/mobile, apps/api)
- [ ] CI/CD pipeline (GitHub Actions → Vercel/Railway)
- [ ] PostgreSQL setup + Redis (Railway or Supabase for Faz 1)
- [ ] Cloudflare R2 bucket (media storage)
- [ ] Firebase project (push notifications)
- [ ] iyzico merchant account + sandbox setup
- [ ] Netgsm account (SMS)
- [ ] Environment management (.env structure, secrets management)

### 🎨 Design
- [ ] Design system setup in Figma (colors, typography, components)
- [ ] Logo finalization (B + block grid, navy + red)
- [ ] Mobile app screens (Sakin, Yönetici, Kapıcı — Faz 1 modules)
- [ ] Web panel screens (Site Yönetici Paneli — Faz 1 modules)
- [ ] Marketing site design
- [ ] Onboarding flow design (per user type)

### 📱 Mobile App (React Native — Faz 1)
- [ ] Project init (Expo managed workflow)
- [ ] Authentication (phone OTP via Netgsm + JWT)
- [ ] Resident app: onboarding → apartment linking
- [ ] Resident app: dues payment (iyzico SDK)
- [ ] Resident app: expense report viewer
- [ ] Resident app: announcements list
- [ ] Resident app: voting screen
- [ ] Resident app: push notification setup
- [ ] Doorman app: entry time logging (login = clock-in)
- [ ] Doorman app: garbage 3-step flow
- [ ] Doorman app: package receipt + resident notification
- [ ] Doorman app: daily task checklist
- [ ] Manager mobile: quick dues view + announcements

### 🖥️ Web Panel (Next.js — Site Yönetici)
- [ ] Authentication + session (NextAuth or custom JWT)
- [ ] Dashboard (dues overview, recent activity)
- [ ] Resident management (add/edit/remove, apartment assignment)
- [ ] Dues setup (amount, date, frequency configuration)
- [ ] Payment tracking (who paid, who didn't, send reminders)
- [ ] Expense entry (categories, receipt upload, R2 storage)
- [ ] Expense report (resident-visible monthly report)
- [ ] Announcement creator (categories, scheduling, pin)
- [ ] Voting/poll creator
- [ ] Decision book
- [ ] Meeting management

### 🔧 Backend API (NestJS — Faz 1 modules)
- [ ] Auth module (OTP, JWT, refresh tokens, role-based)
- [ ] Site/apartment data model + CRUD
- [ ] Resident onboarding + invitation flow
- [ ] Dues module (calculation, payment webhook from iyzico, late fees)
- [ ] Expense module (CRUD, file upload to R2)
- [ ] Announcement module (CRUD, push notification trigger)
- [ ] Voting module (create poll, cast vote, auto-close + announce)
- [ ] Decision book module
- [ ] Doorman module (clock-in, task tracking, garbage log, package log)
- [ ] Notification service (Firebase FCM + Netgsm SMS unified)
- [ ] iyzico integration (payment intent, webhook, commission calculation)

### 🌐 Marketing Site (Next.js)
- [ ] Landing page (hero, features, how it works, demo CTA)
- [ ] Pricing page
- [ ] Contact form
- [ ] KVKK / Privacy Policy pages
- [ ] Schema.org JSON-LD
- [ ] Basic SEO setup (hreflang TR/EN for Faz 1)

### ⚖️ Legal & Compliance
- [ ] KVKK privacy policy + explicit consent flow
- [ ] iyzico merchant agreement
- [ ] Data processing agreement template (for site managers)
- [ ] BDDK license research + application timeline
- [ ] Terms of service

---

## 12. Surface Inventory

### Web Surfaces
| Surface | URL | Faz |
|---------|-----|-----|
| Marketing site | blocero.com | 1 |
| Site manager panel | app.blocero.com | 1 |
| Super admin panel | admin.blocero.com | 1 |
| Demo site | demo.blocero.com | 1 |
| Ad platform | ads.blocero | 2 |
| B2B panel | b2b.blocero.com | 2 |
| Blog | blocero.com/blog | 2 |

### Mobile Apps
| App | Stores | Faz |
|-----|--------|-----|
| Blocero (Sakin + Kapıcı + Yönetici mobil) | App Store + Play Store | 1 |
| Usta | App Store + Play Store | 2 |
| Şoför | App Store + Play Store | 2 |
