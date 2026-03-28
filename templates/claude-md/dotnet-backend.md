# {PROJECT_NAME}

## Quick Reference
- **Type**: .NET Backend API
- **Stack**: .NET 10, EF Core, PostgreSQL
- **Solution**: {SOLUTION_NAME}.sln
- **Path**: {PROJECT_PATH}

## Architecture
- Clean Architecture (Domain -> Application -> Infrastructure -> API)
- CQRS with MediatR
- EF Core Code-First with PostgreSQL
- FluentValidation for request validation
- OpenTelemetry for observability

## Project Structure
```
src/
├── {Name}.Domain/           # Entities, value objects, domain events
├── {Name}.Application/      # Use cases, handlers, DTOs, validators
├── {Name}.Infrastructure/   # External services, email, storage
├── {Name}.EntityFrameworkCore/  # DbContext, migrations, repositories
└── {Name}.API/              # Minimal API endpoints, middleware
```

## Commands
- Build: `dotnet build`
- Test: `dotnet test`
- Run: `dotnet run --project src/{Name}.API`
- Migration: `dotnet ef migrations add {Name} --project src/{Name}.EntityFrameworkCore`
- Update DB: `dotnet ef database update --project src/{Name}.EntityFrameworkCore`

## Database
- Provider: PostgreSQL (centralized at ~/workspace/docker/)
- Connection: See appsettings.Development.json or environment variables
- NEVER modify database directly — always use EF Core migrations

## Authentication
- {OpenIddict / JWT / None — specify}

## Known Issues / Gotchas
- {Add as discovered}
