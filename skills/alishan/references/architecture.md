# Architecture

On an **existing** project, extend its structure. Restructure only when asked, and one feature at a time.

## Contents
- Layers and what each must not do
- Feature-first folders
- Repositories
- Dependency injection
- Review checklist

## Layers

| Layer | Contains | Must not |
|---|---|---|
| presentation | screens, widgets, state holders, view models | call HTTP/DB; hold business rules |
| domain | immutable entities, pure rules, use cases, repository **interfaces**, `AppError` | import Flutter, HTTP, SDK or JSON code |
| data | repository impls, remote/local sources, DTOs + mappers, cache | leak DTOs or SDK types upward; throw raw exceptions upward |

Dependencies point inwards. Use cases are optional: add one when logic spans several repositories or several screens.

## Folders

```
lib/
├── app/          router, DI, theme, env/flavors, main wiring
├── core/         tokens, Result/AppError, network client, shared widgets, extensions
└── features/<name>/{domain,data,presentation}/
```

- A feature may import `core/` and another feature's `domain/`, **never** its `data/` or `presentation/`. When two features need the same helper (an exception type, an error mapper, a skeleton widget), promote it to `core/`. Don't import across features.
- Generated SDK models (Amplify, OpenAPI, GraphQL codegen) are DTOs. Map them in data; never pass them into widgets.

## Repositories

- Return `Result<T>` (see [functional-programming.md](functional-programming.md)). Translate exceptions to `AppError` in **one** guard function per app, not in each method.
- The repository is the single source of truth for its data: it decides between cache and network, and writes through to the cache.
- Read the body of every non-2xx response, not only 400s. Rate limits and field errors live in other status codes.

## Dependency injection

Wire the graph in one place (`app/di.dart`) with whatever the project uses (`get_it`, Riverpod providers, `RepositoryProvider`). Constructors take interfaces, so tests pass fakes. Never call a service locator from inside widgets or rules.

## Review checklist

```
- [ ] domain/ imports nothing from Flutter, HTTP, SDK or JSON
- [ ] no DTO or SDK type in presentation
- [ ] build() is pure: no I/O, no navigation, no setState
- [ ] state is immutable and sealed
- [ ] failures cross layers as Result/AppError
- [ ] dependencies are constructor-injected interfaces
- [ ] no feature imports another feature's data/ or presentation/
```

For a complete, tested example to copy patterns from, see [../examples/profile_feature/](../examples/profile_feature/).
