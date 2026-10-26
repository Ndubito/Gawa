# Gawa Code Review Standards

These are the standards Claude must enforce on every PR for the Gawa project.

---

## Architecture

**Flutter (feature structure):**
- Every feature must live under `lib/features/<feature>/` with exactly these subdirectories:
  - `data/` — repository implementations, API calls (Dio), models with `fromJson`
  - `domain/entities/` — plain Dart model classes, no Flutter/Dio imports
  - `domain/repos/` — abstract repository interfaces
  - `presentation/cubits/` — BLoC Cubits; no HTTP/Dio here, only calls through the repo interface
  - `presentation/pages/` — full-screen pages
  - `presentation/widgets/` — reusable widgets scoped to this feature
- **Violation**: business logic in a page/widget, Dio calls in a cubit, or direct `http` imports in `domain/`.

**NestJS (backend structure):**
- Every module must follow: domain entities → use cases (application layer) → infrastructure (Prisma) → presentation (controllers + DTOs)
- Controllers must be thin: receive request, call a use case, return the result. No business logic.
- Use cases must accept domain entities or primitive types, never raw DTOs.
- **Violation**: Prisma queries in a controller, business logic in a DTO, or entities importing NestJS decorators.

---

## Security

- **Firebase guard**: Every endpoint that touches user data must be decorated with `@UseGuards(FirebaseAuthGuard)`. No exceptions.
- **Owner from token, never from body**: The `requesterId`/`ownerId` must always be derived from the decoded Firebase token via `SyncFirebaseUserUseCase`. If a DTO or request body contains `ownerId`, `userId`, or `requesterId` that is used for access control — that is a critical security bug.
- **Ownership errors return 404**: When a non-owner tries to access/modify a resource, throw `NotFoundException`, not `ForbiddenException`. This prevents leaking resource existence.
- **Soft-delete filter**: Every Prisma `findMany`, `findFirst`, or `findUnique` on a model that has `deleted_at` must include `where: { deleted_at: null }`. Missing this filter is a security/correctness bug.
- **No committed secrets**: The PR must not add `.env` files, `firebase-service-account.json`, API keys, or any credential material to the repo. These are gitignored and must stay that way.

---

## Phone Numbers

- All Kenyan phone numbers stored or compared must be in E.164 format (`+254XXXXXXXXX`).
- In Flutter, always run user-supplied phone strings through `normalizeKenyanPhone()` from `lib/core/phone_number.dart` before storing or sending them to the API.
- In the backend, the phone number received from the client should already be normalized; the use case should validate it is in E.164 format before persisting.
- **Violation**: storing `07...` or `254...` formats raw, or skipping normalization.

---

## Testing

- Every new use case or cubit must have a corresponding unit test.
- Backend tests use mock/in-memory repositories (not a real database).
- Flutter tests use fake repository implementations (not mock HTTP).
- No `print` statements or `console.log` left in production code paths.
- **Violation**: a new feature file with no associated test file in the PR.

---

## Flutter-specific

- Always check `mounted` before calling `setState`, `ScaffoldMessenger`, or `Navigator` after an `await`.
- `BlocProvider` scope: provide a cubit at the lowest widget ancestor that needs it. Do not provide feature-specific cubits at the root `app.dart` unless they are truly app-wide (e.g. `AuthCubit`).
- `AuthCubit.backendUser` (integer `id`) must be used for ownership comparisons, not the Firebase UID string.
- Use `context.read<X>()` inside callbacks/handlers; use `BlocBuilder`/`BlocListener` for reactive UI — never call `context.watch<X>()` inside `build()` methods outside a `BlocBuilder`.

---

## NestJS-specific

- Use NestJS `Logger` instead of `console.log` for all server-side logging.
- DTOs must use `class-validator` decorators (`@IsString()`, `@IsOptional()`, etc.) for every field.
- Never return raw Prisma model objects from controllers; always map to a response DTO or plain object.
- `async/await` must be properly awaited — never fire-and-forget a Promise unless intentional and documented.

---

## Branch & PR Rules

- Feature branches must be named `feature/*` and target the `development` branch — **not `main`**.
- Fix branches must be named `fix/*` and also target `development`.
- A PR that merges a `feature/*` or `fix/*` branch directly into `main` should be flagged as a process violation.
- PR title should describe what changed, not just "fix" or "update".

---

## General Quality

- No commented-out code blocks. Remove dead code entirely.
- No `TODO` comments added in this PR without an accompanying issue reference.
- Error messages shown to users must not expose server internals (stack traces, SQL errors, file paths).
- New dependencies (Flutter packages or npm packages) must be flagged in the review with a note asking whether they were approved by the team.
