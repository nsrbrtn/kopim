Готово. Ниже обновлённый `AGENTS.md` с правилом о языке.

---

# AGENTS.md

**Project:** kopim
**Stack:** Flutter, Riverpod, Freezed, Drift, Firebase
**Targets:** Android, iOS, Web, Desktop

## 0) Language Policy

* Все ответы ИИ — **на русском языке**.
* Любые пояснения к коду, комментарии в PR, описания коммитов и документация — **на русском языке**.

## 1) Objectives

* Ship a modern, scalable, secure finance app.
* Follow Clean Architecture + DDD and feature-first modularity.
* Offline-first with robust sync.
* Measure and improve performance with real profiling.

## 2) Architecture Rules

* Layers per feature: `presentation/`, `domain/`, `data/`.
* Domain is UI/infra-free. All entities immutable (Freezed).
* DI via Riverpod. Use `.select` to cut rebuilds on hot paths.
* Local DB = Drift. Open DB off the UI isolate.
* Remote = Firebase (Auth, Firestore, Performance).

## 3) Performance Ground Rules

* Profile on device in **profile** mode; do not measure in debug.
* Lists: use `itemExtent` or `prototypeItem` when possible; keep rows light; cache formatters.
* Reduce shader jank with SkSL warm-up for release builds.
* Move I/O and heavy CPU off the UI isolate (Drift background open).
* Add Firebase Performance traces for cold start and first scroll.

## 4) Offline-first + Sync

* Write to Drift first. Sync to Firestore when online.
* Conflict policy: `last-write-wins` unless domain specifies merge.
* Idempotent upserts; exponential backoff on retries.

## 5) Testing Policy

* **Unit:** entities, mappers, use cases.
* **Widget:** list rows, empty states, error UI.
* **Integration:** DB + sync; transaction insert updates account balance and appears in analytics.
* Tests must run headless and pass on CI.

## 6) Source of Truth: repo structure

* See current tree and modules in the repository root. Keep new code within its feature module.

## 7) Agent Operating Procedure (AOP)

**Goal:** maximize AI efficiency, minimize risk.

* Work in small, focused PRs. One concern per commit.
* Always start with a profile trace or a failing test, then fix, then re-measure.
* Prefer additive changes over refactors unless metrics demand it.
* Generate code that compiles, is formatted, and covered by tests.
* Human-in-the-loop: require review for any data-deleting or schema-changing action; keep change logs. Enforce least privilege and observability.
* Expectation management: use AI for scaffolding, boilerplate, exploration; humans own final judgment.
* Prompt hygiene: provide context, constraints, acceptance tests, and repo paths; iterate with short cycles.
* **Documentation:** при создании кастомного компонента/виджета или архитектурного решения — обязательно создать документ в `docs/components/` (для UI-виджетов) или `docs/logic/` (для бизнес-логики) с описанием назначения, параметров, примеров использования и ссылками на исходный код.

## 8) Definition of Done (per PR)

* `flutter analyze` clean and formatted.
* All tests pass. New logic covered by unit and at least one widget or integration test.
* No sync or heavy CPU on the UI isolate.
* For perf PRs: attach before/after DevTools traces and explain wins.
* Public APIs unchanged unless explicitly scoped.

## 9) Tasks by Functional Groups

### Accounts

* Entity: `Account { id, name, balance, currency, type }` (Freezed).
* Repo contracts in `domain/`, Drift DAO in `data/`, Firebase adapter in `data/remote/`.
* List screen: fixed-height rows, memoized formatters, `.select` on row leaves.

### Transactions

* Entity: `Transaction { id, accountId, categoryId, amount, date, note, type }`.
* Invariants: positive `amount`; account/category exist; debit/credit logic correct.
* Insert/update inside a DB transaction that also updates account balance.
* Home feed performance: `itemExtent` или `prototypeItem`, leaf `ConsumerWidget`s, cached `DateFormat/NumberFormat`.

### Categories

* Entity: `Category { id, name, type, icon, color }`.
* Icon registry: curated set only, no runtime search across thousands.

### Analytics

* Aggregation queries in Drift; ensure they run off the UI isolate.

### Auth/Profile

* Initialize Firebase after first frame; show skeleton UI until ready.
* Add Firebase Performance custom traces.

### Budgets

* Model budget and compute utilization via Drift queries; unit tests for edge cases.

### Recurring Transactions

* Store RRULE-like fields; deterministic next-occurrence; pause/resume; integration tests with time travel.

### AI Financial Assistant

* Local service reads Drift data. Privacy-safe. Answers simple queries like “spend on Food this month”.

## 10) Commands

```bash
# Format, analyze, build code-gen, test, dependency health
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
flutter pub outdated
```


## 11) Code Quality Conventions

* Enforce immutability with Freezed; value equality required.
* Widget micro-optimizations: use `const`, split large trees, avoid heavy work in `build`.
* For lists: stable keys, minimal work per item, avoid large SVGs in hot paths.

## 12) Observability & Safety for AI Changes

* Restrict credentials and destructive permissions in automation.
* Log agent actions and keep rollback plans for schema/data ops.
* Require post-merge validation against benchmarks.
