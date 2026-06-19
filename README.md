
# Gawa

### Stop chasing your friends for money.

**Gawa is a notification-driven payment layer on top of M-Pesa.** It reminds the people in a shared bill when their share is due, pending, or overdue — so the person who fronts the money never has to send another awkward "hey, you still owe me" text.
<div align='center'>
  
[![Backend](https://img.shields.io/badge/backend-NestJS%2011-E0234E?logo=nestjs&logoColor=white)](#-tech-stack)
[![App](https://img.shields.io/badge/app-Flutter-02569B?logo=flutter&logoColor=white)](#-tech-stack)
[![Database](https://img.shields.io/badge/db-PostgreSQL%20%2B%20Prisma%207-4169E1?logo=postgresql&logoColor=white)](#-tech-stack)
[![Auth](https://img.shields.io/badge/auth-Firebase-FFCA28?logo=firebase&logoColor=black)](#-the-auth-bridge)

</div>

---

## The problem

Splitting recurring costs — a family Netflix plan, a shared Spotify account, group rent, a gym membership — almost always falls on one person. They pay the full bill up front, then spend the rest of the month reminding everyone else to send their share. It's tedious, it's awkward, and money slips through the cracks.

## The solution

Gawa automates the reminding. You create a **group**, add **members** by phone number, and attach a **subscription** (the shared bill). Gawa then notifies each member when their share is due. When they tap the notification, they're taken straight to a screen to pay **their** portion — via a direct M-Pesa person-to-person transfer from the payer's phone to the payee's.

> **Gawa never holds or processes your money.** It's a reminder-and-routing layer on top of M-Pesa P2P — the funds always move directly between the two people. M-Pesa accounts are linked by phone number and changeable in settings.

### How it works

```
Create a group  →  Add members (by phone)  →  Attach a subscription (the shared bill)
                                                          │
                          Gawa splits it equally and tracks each member's share
                                                          │
        🔔 "Your KES 500 share of Family Netflix is due"  ──tap──▶  Pay via M-Pesa P2P
```

---

## Features

| Status | Feature | What it does |
| :----: | :------ | :----------- |
| ✅ | **Phone authentication** | Sign in with an SMS one-time code via Firebase. |
| ✅ | **Groups** | Create and manage groups for each shared bill. Ownership is enforced server-side. |
| ✅ | **Members** | Invite people by phone number — even before they've installed Gawa. Their account links automatically on first sign-in. |
| ✅ | **Subscriptions** | Attach a recurring monthly bill to a group; the cost is split equally between members. |
| 🚧 | **Cycles & obligations** | Roll each subscription over every billing period and track exactly who owes what. |
| 🗺️ | **Push notifications** | Remind members when a payment is upcoming, pending, or overdue (Firebase Cloud Messaging). |
| 🗺️ | **Pay flow (M-Pesa)** | Tap a reminder → pay your share via M-Pesa STK Push (Daraja). |
| 🗺️ | **Basic / Pro tiers** | Free tier with a group limit; Pro unlocks more. |

<sub>✅ shipped · 🚧 in progress · 🗺️ planned</sub>

---

## Architecture

Gawa is a **monorepo** with a Flutter client and a NestJS API, both built on **clean architecture** — domain logic is isolated from frameworks, so the rules that matter live in plain, testable code.

```
gawa/
├── app/flutter_1/          # Flutter mobile client
│   └── lib/
│       ├── core/           # shared utilities (API client, phone normalization, enums)
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
    A[Flutter app<br/>Cubit + Dio] -->|Firebase ID token| B[FirebaseAuthGuard]
    B -->|verified token| C[SyncFirebaseUserUseCase]
    C -->|resolves backend user id| D[Use case<br/>business rules]
    D -->|via repository interface| E[(PostgreSQL<br/>Prisma 7)]
```

### The auth bridge

A small piece I'm particularly happy with. Firebase handles the SMS one-time-code sign-in, but the backend needs a stable identity to own data. So:

1. The Flutter app attaches the Firebase **ID token** to every request (a Dio interceptor).
2. A NestJS guard **verifies** that token with the Firebase Admin SDK.
3. `SyncFirebaseUserUseCase` resolves it to a backend `User` row — by `firebase_uid`, falling back to phone number — creating or linking the row as needed.

This also powers **invite-before-signup**: adding an unknown phone number creates a placeholder user, and the bridge automatically links it the first time that person signs in.

### Security model

Security is designed in, not bolted on:

- **Owner is never trusted from the client.** Ownership is always derived from the verified token, server-side. A request body can't claim to be someone else.
- **No existence leaks.** Accessing a resource you don't own returns `404`, not `403` — so you can't probe for which groups or subscriptions exist.
- **Soft deletes everywhere.** Every read filters `deleted_at IS NULL`; nothing is hard-deleted.
- **Secrets stay out of git.** The Firebase service-account key and all `.env` files are git-ignored.
- **Automated review.** Every pull request is checked by a Claude-powered GitHub Action against a project-specific [standards file](.github/REVIEW_STANDARDS.md).

---

## Tech stack

| Layer | Technology |
| :---- | :--------- |
| **Mobile** | Flutter · Dart · `flutter_bloc` (Cubit pattern) · Dio · `go_router` · Google Fonts |
| **Auth** | Firebase Authentication (phone / OTP) |
| **API** | NestJS 11 · TypeScript · class-validator |
| **Data** | PostgreSQL · Prisma 7 |
| **Server auth** | Firebase Admin SDK |
| **Tooling** | Jest · Flutter test · ESLint · Prettier · Docker · automated PR review |

The data model is a fully-relational financial domain: `User`, `Group`, `GroupMember`, `Subscription`, `SubscriptionMember`, `SubscriptionCycle`, `Expense`, `ExpenseSplit`, `Obligation`, `Payment`, and `Transaction` — designed up front to support reminders, splits, and an auditable payment trail.

---

## Getting started

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

---

## Testing

```bash
# Backend (Jest)
cd services/api/gawa && npm test

# App (Flutter)
cd app/flutter_1 && flutter test
```

Use cases and Cubits are covered by unit tests with in-memory fakes — including the ownership and membership rules that protect every endpoint.

---

## Roadmap

- [x] Firebase ↔ backend auth bridge
- [x] Groups (CRUD, secured ownership)
- [x] Group members (invite by phone, auto-link on signup)
- [x] Subscriptions (group-scoped, equal split)
- [ ] Billing cycles & per-member obligations
- [ ] Push notifications (upcoming / pending / overdue)
- [ ] M-Pesa pay flow (Daraja STK Push)
- [ ] Basic / Pro monetization tiers

---

## Repository layout

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
