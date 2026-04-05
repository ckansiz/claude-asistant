# ADR-001: No MediatR — Custom CQRS Abstractions

**Date**: 2025-Q4
**Status**: Accepted
**Projects**: qoommerce, all new .NET projects

## Decision

Do not use MediatR. Implement CQRS with custom `ICommand<T>`, `IQuery<T>`, `ICommandHandler<TCommand, TResult>`, `IQueryHandler<TQuery, TResult>` interfaces in a dedicated `{Project}.Core` layer.

## Rationale

- MediatR adds indirection without benefit at this project scale
- Custom interfaces are simpler, easier to trace in the debugger
- Avoids pulling in a dependency for a pattern that's trivial to implement
- Handlers are registered directly via DI — no pipeline magic needed

## Consequences

- Every new project needs `ICommand`, `IQuery`, `Result<T>` bootstrapped in `{Project}.Core`
- Handlers are resolved from DI in endpoints directly — no `ISender.Send()`
- No pipeline behaviors (logging, validation must be done explicitly or via endpoint middleware)

## Applied in `dotnet.md` context file.
