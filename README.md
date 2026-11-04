<div align="center">

# 💸 Gawa

### Stop chasing your friends for money.

**Gawa is a notification-driven payment layer on top of M-Pesa.** It reminds the people in a shared bill when their share is due, pending, or overdue — so the person who fronts the money never has to send another awkward "hey, you still owe me" text.

[![Backend](https://img.shields.io/badge/backend-NestJS%2011-E0234E?logo=nestjs&logoColor=white)](#-tech-stack)
[![App](https://img.shields.io/badge/app-Flutter-02569B?logo=flutter&logoColor=white)](#-tech-stack)
[![Database](https://img.shields.io/badge/db-PostgreSQL%20%2B%20Prisma%207-4169E1?logo=postgresql&logoColor=white)](#-tech-stack)
[![Auth](https://img.shields.io/badge/auth-Firebase-FFCA28?logo=firebase&logoColor=black)](#-the-auth-bridge)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)](#-testing)

</div>

---

## 🎯 The problem

Splitting costs — a family Netflix plan, a shared Spotify account, group rent, a dinner out — almost always falls on one person. They pay the full bill up front, then spend the rest of the month reminding everyone else to send their share. It's tedious, it's awkward, and money slips through the cracks.

## 💡 The solution

Gawa automates the reminding. You create a **group**, invite **members** by phone number, and attach a **subscription** (a recurring bill) or log an **expense** (a one-off cost you paid). Gawa splits it, tracks who owes what, and reminds each person when their share is due. Tapping a reminder takes them straight to paying **their** portion with M-Pesa.

> **How the money moves (in development).** Payments run on M-Pesa through Safaricom's Daraja API. A member pays their share to Gawa's paybill with an M-Pesa prompt on their phone, and Gawa immediately sends it on to the person who's owed. Gawa only holds money in the minutes between those two steps, and every shilling in is reconciled against every shilling out. See [How the money moves](#-how-the-money-moves).

### How it works

```
Create a group  →  Invite members (by phone)  →  Attach a subscription or log an expense
                                                          │
                              Gawa splits it and tracks each member's share
                                                          │
     🔔 "Your KES 500 share of Family Netflix is due"  ──tap──▶  Pay with an M-Pesa prompt
                                                          │
                                 Gawa pays the person who's owed
```

---

## ✨ Features

| Status | Feature | What it does |
| :----: | :------ | :----------- |
| ✅ | **Phone authentication** | Sign in with an SMS one-time code via Firebase. |
| ✅ | **Groups** | Create and manage groups for each shared bill. Ownership is enforced server-side. |
| ✅ | **Members & invites** | Invite people by phone number — even before they've installed Gawa. They accept or decline before they can see the group; their account links automatically on first sign-in. |
| ✅ | **Subscriptions** | Attach a recurring bill to a group; the owner and members share it equally. |
| ✅ | **Billing cycles** | A scheduled engine bills each period three days ahead, creates every member's share, and marks unpaid shares overdue after the grace period. |
| ✅ | **Expenses** | Log a one-off cost you paid and split it equally with chosen group members. |
| ✅ | **Bills** | See everything you owe and are owed, grouped by urgency, with totals on the home screen. |
| 🚧 | **Pay with M-Pesa** | Pay your share from an M-Pesa prompt (STK Push); Gawa pays the recipient straight away (B2C). |
| 🗺️ | **Push notifications** | Deliver the queued reminders — upcoming, due, overdue — as push notifications that open the pay screen. |
| 🗺️ | **Ad-hoc expenses** | Split a one-off cost with contacts — no group needed. |
| 🗺️ | **Itemised receipts** | Scan a receipt; each person claims the items they had and pays for just those. |
| 🗺️ | **Basic / Pro tiers** | Free tier with a group limit; Pro unlocks more. |

<sub>✅ shipped · 🚧 in progress · 🗺️ planned</sub>

---

## 🔁 How the money moves

Every feature feeds the same pipeline: something creates a **bill** (an obligation for one person to pay one other person), the bill gets a queue of **reminders**, and the bill is settled by a **payment** that Gawa passes on as a **payout**. Dashed boxes are planned.

```mermaid
flowchart LR
    subgraph Sources["What creates a bill"]
        S1["Subscription cycle"]
        S2["Group expense"]
        S3["Ad-hoc expense"]:::planned
        S4["Itemised receipt"]:::planned
    end

    S1 --> B["Bill<br/>(one person owes another)"]
    S2 --> B
    S3 -.-> B
    S4 -.-> B

    B --> R["Reminder queue<br/>upcoming · due · overdue · nudges"]
    R -.-> P["Push notification"]:::planned
    P -.-> PAY["Pay with M-Pesa<br/>STK Push into Gawa"]:::planned
    B --> PAY
    PAY -.-> OUT["Payout to recipient<br/>B2C from Gawa"]:::planned

    classDef planned stroke-dasharray: 5 5
```

### The life of a bill

```mermaid
stateDiagram-v2
    [*] --> PENDING: created by a cycle or an expense
    PENDING --> OVERDUE: grace period passes unpaid
    PENDING --> PAID: member's M-Pesa payment confirmed
    OVERDUE --> PAID: member's M-Pesa payment confirmed
    PENDING --> CANCELLED: subscription paused/deleted or member left,<br/>before the due date
    PENDING --> CANCELLED: payer deletes the expense
    OVERDUE --> CANCELLED: payer deletes the expense
    PAID --> [*]
    CANCELLED --> [*]
```

A bill is **paid** the moment the member's money arrives — what happens to the payout afterwards is Gawa's job, not theirs. Expense debts survive a member leaving the group; subscription bills that aren't due yet do not.

### ✅ Billing cycles (shipped)

A scheduled tick runs every 15 minutes. It's safe to run twice: the database refuses a second cycle for the same period.

```mermaid
flowchart TD
    T["Billing tick, every 15 min"] --> Q{"Any active subscription<br/>with a period due within 3 days<br/>not yet billed?"}
    Q -- yes --> C["Create the cycle"]
    C --> O["One bill per accepted member<br/>amount = total ÷ (members + owner)"]
    O --> R["Queue reminders at 09:00 Nairobi:<br/>3 days before · due day · overdue · 3 nudges"]
    Q -- no --> M
    R --> M["Mark unpaid bills past their grace period OVERDUE"]
```

### 🚧 Pay with M-Pesa — STK Push in, B2C out

The member pays their share **plus a small visible fee**, so the person who's owed receives the full amount. Gawa never pays out from a callback directly: a payout is queued in the same database transaction that marks the bill paid, and a worker sends it.

```mermaid
sequenceDiagram
    autonumber
    actor Member
    participant App as Gawa app
    participant API as Gawa API
    participant Daraja as Safaricom Daraja
    actor Recipient

    Member->>App: Tap "Pay KES 1,000 + fee"
    App->>API: POST /payments (bill id)
    API->>API: Check the member owes this open bill,<br/>then save the payment as PENDING
    API->>Daraja: STK Push for share + fee
    Daraja-->>Member: M-Pesa PIN prompt on their phone
    Member->>Daraja: Enter PIN
    Daraja->>API: STK callback (paid / failed)
    API->>API: One transaction: record it, payment SUCCEEDED,<br/>bill PAID, payout QUEUED
    App->>API: Poll the payment
    API-->>App: Paid ✓

    loop Payout worker, every minute
        API->>Daraja: B2C payment to the recipient's verified number
        Daraja->>API: Result callback
        API->>API: Payout SUCCEEDED
    end
    Daraja-->>Recipient: M-Pesa receives KES 1,000
```

Payouts are where money can go wrong, so they have their own careful lifecycle. A **timeout never triggers a resend** — it might have gone through — so Gawa asks M-Pesa first.

```mermaid
stateDiagram-v2
    [*] --> QUEUED: member's payment confirmed
    QUEUED --> SENT: worker sends B2C
    SENT --> SUCCEEDED: result says paid
    SENT --> FAILED: result says failed
    SENT --> UNKNOWN: no result (timeout)
    UNKNOWN --> SUCCEEDED: status check says paid
    UNKNOWN --> FAILED: status check says failed
    FAILED --> QUEUED: retry (fewer than 3 attempts)
    FAILED --> NEEDS_REVIEW: 3 attempts used
    NEEDS_REVIEW --> QUEUED: re-queued by hand
    SUCCEEDED --> [*]
```

A daily reconciliation checks that **money in = payouts + fees + money still held**, and raises an alert if it doesn't.

### 🗺️ Push notifications

The billing engine already queues every reminder; this feature delivers them. Reminders for bills that are already paid or cancelled are skipped at send time.

```mermaid
sequenceDiagram
    autonumber
    participant App as Gawa app
    participant API as Gawa API
    participant FCM as Firebase Cloud Messaging
    actor Member

    App->>API: Register this device's push token (on sign-in)
    loop Reminder worker
        API->>API: Find reminders due now, unsent,<br/>whose bill is still unpaid
        API->>FCM: Send "Your KES 500 share of Netflix is due"
        API->>API: Mark the reminder sent
    end
    FCM-->>Member: Push notification
    Member->>App: Tap it
    App->>App: Open the pay screen for that bill
```

### 🗺️ Ad-hoc expenses

Split something with people who aren't in a group together — or pick an existing group as today. Because anyone could otherwise send anyone a "you owe" message, people added by phone **accept or dispute** before any reminders start.

```mermaid
flowchart TD
    A["Payer: 'Add expense'"] --> W{"Split with…"}
    W -- an existing group --> G["Pick accepted members<br/>(how expenses work today)"]
    W -- contacts --> C["Pick people by phone<br/>(invited if they're not on Gawa)"]
    C --> RQ["Each person sees:<br/>'Mary says you owe KES 1,000 for Dinner'"]
    RQ --> D{"Accept or dispute?"}
    D -- accept --> BILL["Bill + reminders start"]
    D -- dispute --> N["Payer is told:<br/>edit the expense or drop that person"]
    G --> BILL
```

<sub>Open decisions for this feature: whether a contact-only expense creates a hidden group or stands on its own (the leaning is to stand alone, using the expense's split as its participant list), and how a contact picker works without a web equivalent.</sub>

### 🗺️ Itemised receipts

Instead of an equal split, each person pays for what they actually had. Scanning is only a shortcut: the payer can always correct the items, so a bad scan never blocks anyone.

```mermaid
flowchart TD
    S["Payer scans the receipt"] --> P["Receipt is read into line items"]
    P --> E["Payer reviews: fixes items,<br/>confirms tax, service charge, tip"]
    E --> I["Payer adds the people who were there"]
    I --> CL["Claiming: each person ticks what they had<br/>(shared items split between those who tick them)"]
    CL --> L{"Everything claimed,<br/>or claiming deadline reached?"}
    L -- not yet --> NR["'Pick your items' reminder"] --> CL
    L -- yes --> U["Unclaimed items handled<br/>(open decision: payer absorbs or split equally)"]
    U --> B["Each person's bill = their items<br/>+ their share of tax, service and tip"]
    B --> PAY["Normal reminders and M-Pesa pay flow"]
```

---

## 🏗️ Architecture

Gawa is a **monorepo** with a Flutter client and a NestJS API, both built on **clean architecture** — domain logic is isolated from frameworks, so the rules that matter live in plain, testable code.

```
gawa/
├── app/flutter_1/          # Flutter mobile client
│   └── lib/
│       ├── core/           # shared utilities (API client, phone normalization, money, enums)
│       └── features/       # one folder per feature, each split into:
│           └── <feature>/
│               ├── data/           # repository implementations (Dio → API)
│               ├── domain/         # entities + repository interfaces
│               └── presentation/   # Cubits (state) · pages · widgets
│
└── services/api/gawa/      # NestJS REST API
    └── src/modules/
        └── <module>/
            ├── domain/         # entities + repository interfaces (no framework code)
            ├── application/    # use cases — the business rules
            ├── infrastructure/ # Prisma repository implementations
            └── presentation/   # controllers + DTOs
```

### The request flow

```mermaid
flowchart LR
    A[Flutter app<br/>Cubit + Dio] -->|Firebase ID token| B[FirebaseAuthGuard<br/>on every route]
    B -->|verified token| C[SyncFirebaseUserUseCase]
    C -->|resolves backend user id| D[Use case<br/>business rules]
    D -->|GroupAccessPolicy| D
    D -->|via repository interface| E[(PostgreSQL<br/>Prisma 7)]
```

### 🔐 The auth bridge

A small piece I'm particularly happy with. Firebase handles the SMS one-time-code sign-in, but the backend needs a stable identity to own data. So:

1. The Flutter app attaches the Firebase **ID token** to every request (a Dio interceptor).
2. A NestJS guard **verifies** that token with the Firebase Admin SDK.
3. `SyncFirebaseUserUseCase` resolves it to a backend `User` row — by `firebase_uid`, falling back to phone number — creating or linking the row as needed.

This also powers **invite-before-signup**: adding an unknown phone number creates a placeholder user, and the bridge automatically links it the first time that person signs in.

### 🛡️ Security model

Security is designed in, not bolted on:

- **Secure by default.** The auth guard runs on every route; anything public has to opt out explicitly, and an end-to-end test fails if a new route ships unguarded.
- **Owner is never trusted from the client.** Ownership and the payer of an expense are always derived from the verified token, server-side. A request body can't claim to be someone else.
- **Roles, checked in one place.** A single group access policy decides whether you're the owner, an accepted member, a pending invitee, or nobody. Invitees see only the invite until they accept.
- **Need-to-know bills.** A bill is visible only to the person who owes it and the person owed — not to the rest of the group.
- **No existence leaks.** Accessing a resource you can't see returns `404`, not `403`.
- **Soft deletes everywhere.** Every read filters `deleted_at IS NULL`; nothing is hard-deleted.
- **Secrets stay out of git.** The Firebase service-account key and all `.env` files are git-ignored.
- **Automated review.** Every pull request is checked by a Claude-powered GitHub Action against a project-specific [standards file](.github/REVIEW_STANDARDS.md).

---

## 🧱 Tech stack

| Layer | Technology |
| :---- | :--------- |
| **Mobile** | Flutter · Dart · `flutter_bloc` (Cubit pattern) · Dio · `go_router` · Google Fonts |
| **Auth** | Firebase Authentication (phone / OTP) |
| **API** | NestJS 11 · TypeScript · class-validator · `@nestjs/schedule` (billing engine) |
| **Data** | PostgreSQL · Prisma 7 |
| **Server auth** | Firebase Admin SDK |
| **Payments** | M-Pesa via Safaricom Daraja — STK Push and B2C *(in development)* |
| **Tooling** | Jest · Flutter test · ESLint · Prettier · Docker · automated PR review |

The data model is a fully-relational financial domain: `User`, `Group`, `GroupMember`, `Subscription`, `SubscriptionCycle`, `Expense`, `ExpenseSplit`, `Obligation`, `Reminder`, `Payment`, and `Transaction` — designed to support reminders, splits, and an auditable payment trail.

---

## 🚀 Getting started

### Prerequisites

- Node.js 20+
- Flutter SDK 3.10+
- PostgreSQL 14+
- A Firebase project (Authentication enabled) and a service-account key

### 1. Backend API

```bash
cd services/api/gawa
npm install

# Configure environment (see below), then:
npx prisma migrate deploy      # apply the schema
npm run start:dev              # http://localhost:8000
```

Create `services/api/gawa/.env`:

```env
DATABASE_URL="postgresql://USER:PASSWORD@localhost:5432/gawa"
PORT=8000
GOOGLE_APPLICATION_CREDENTIALS="firebase-service-account.json"
```

> Place your Firebase service-account JSON at `services/api/gawa/firebase-service-account.json`. It is git-ignored and must never be committed.

### 2. Flutter app

```bash
cd app/flutter_1
flutter pub get
flutter run
```

> The app talks to `http://localhost:8000`. On the Android emulator, use `http://10.0.2.2:8000`.

To test phone sign-in in a local web build with a [Firebase test phone number](https://firebase.google.com/docs/auth/flutter/phone-auth#testing_with_fictional_phone_numbers), skip reCAPTCHA with:

```bash
flutter run -d chrome --dart-define=DISABLE_APP_VERIFICATION=true
```

Real phone numbers stop working while this is on — never use it for a release build.

---

## 🧪 Testing

```bash
# Backend (Jest) — unit tests, then end-to-end auth coverage
cd services/api/gawa && npm test && npm run test:e2e

# App (Flutter)
cd app/flutter_1 && flutter test
```

Use cases and Cubits are covered by unit tests with in-memory fakes — including the ownership, membership, and visibility rules that protect every endpoint, and the billing calendar's date maths (month-end clamping, leap years, Nairobi time).

---

## 🗺️ Roadmap

- [x] Firebase ↔ backend auth bridge
- [x] Groups (CRUD, secured ownership)
- [x] Group members (invite by phone, auto-link on signup)
- [x] Subscriptions (group-scoped, equal split)
- [x] Default-deny API auth with group roles and invite acceptance
- [x] Billing cycles & per-member obligations, with queued reminders
- [x] One-off expenses (equal split among chosen members)
- [x] Bills in the app (what I owe / what I'm owed)
- [ ] Pay with M-Pesa — STK Push in, B2C payout to the recipient, with reconciliation
- [ ] Push notifications (upcoming / due / overdue)
- [ ] Ad-hoc expenses — split with contacts without making a group; participants accept or dispute before reminders start
- [ ] Itemised receipt splitting — the payer scans the receipt, members claim the items they had and pay for those
- [ ] Basic / Pro monetization tiers

---

## 📁 Repository layout

| Path | Description |
| :--- | :---------- |
| `app/flutter_1/` | Flutter mobile client |
| `services/api/gawa/` | NestJS REST API + Prisma schema |
| `.github/` | CI workflows + automated code-review standards |
| `compose.yaml` · `Dockerfile` | Containerized deployment |
| `postman/` | API request collections |

---

<div align="center">

**Gawa** — built so you can split the bill, not the friendship.

</div>
