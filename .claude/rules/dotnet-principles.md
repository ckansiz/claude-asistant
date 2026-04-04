# .NET Project Principles

**Applies to:** New .NET projects and Qoommerce/PostHive style projects.

> **Note:** Loodos/MEP uses a different pattern (AppService + Traditional Controllers, .NET 7).
> These principles apply to new projects. Do NOT force-migrate MEP.

## Solution Layer Structure

```
src/
  {Project}.Domain/               # Entities, Value Objects, Repository Interfaces
  {Project}.Application/          # Commands, Queries, Validators, DTOs
  {Project}.Core/                 # Shared abstractions: ICommand, IQuery, Result<T>
  {Project}.Infrastructure/       # Handler implementations, external services
  {Project}.EntityFrameworkCore/  # DbContext, Migrations, EF configurations
  {Project}.Provider/             # ASP.NET Core host: Endpoints, Middleware, DI
```

Dependency flow: Domain ← Application ← Infrastructure ← Provider; Domain ← Core

## CQRS Pattern (No MediatR)

- Use custom `ICommand<TResult>` and `IQuery<TResult>` interfaces from Core layer
- Command → Application layer definition + FluentValidation validator
- Command → Infrastructure layer handler implements `ICommandHandler<TCommand, TResult>`
- Query → Application layer definition; QueryHandler implements `IQueryHandler<TQuery, TResult>`
- Full code patterns: invoke `/dotnet-reference` when writing a handler

## Result Pattern

**Never throw business exceptions.** Return `Result<T>` from all handlers:
- `Result<T>.Success(value)` for success path
- `Result<T>.Failure(error)` for business errors
- Handler caller checks `result.IsSuccess` and branches accordingly

Full `Result<T>` class implementation: see `/dotnet-reference`

## Minimal API Endpoints (No Controllers)

- Use `MapGroup()` for organizing related endpoints: `app.MapGroup("/api/products")`
- Inject handler via DI: `async (... ICommandHandler<...> handler, ...)`
- All endpoints must include XML doc comments (`/// <summary>`)
- Use `Produces<T>()`, `ProducesProblem()` for OpenAPI metadata
- Always return `Result<T>` from handlers; endpoint returns `Ok(result.Value)` or error

## HTTP Status Codes

| Scenario | Code |
|----------|------|
| Success with data | 200 OK |
| Resource created | 201 Created |
| Success no data | 204 NoContent |
| Validation error | 400 BadRequest |
| Unauthorized | 401 Unauthorized |
| Forbidden | 403 Forbidden |
| Not found | 404 NotFound |
| Conflict (duplicate) | 409 Conflict |

## OpenAPI / Scalar (Mandatory)

Every project MUST expose OpenAPI spec:
- `builder.Services.AddOpenApi()`
- `app.MapOpenApi()` → serves `/openapi/v1.json`
- `app.MapScalarApiReference()` → serves `/scalar/v1` (docs UI)
- XML doc comments on every endpoint required for useful TypeScript codegen

## EF Core

- **Code-first migrations only** — never `EnsureCreated()` in production
- `EFCore.NamingConventions` for snake_case column names: `UseSnakeCaseNamingConvention()`
- Entity configuration: use `IEntityTypeConfiguration<T>` classes, not inline `OnModelCreating`
- Migration naming: `dotnet ef migrations add Add{Entity}Table`

## Package Management

Use `Directory.Packages.props` for centralized versioning at solution root:
```xml
<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
<ItemGroup>
  <PackageVersion Include="PackageName" Version="X.Y.Z" />
</ItemGroup>
```

In `.csproj` files, omit versions: `<PackageReference Include="PackageName" />`

## Observability (OpenTelemetry)

Required in every project:
- `builder.Services.AddOpenTelemetry()` with tracing + metrics
- Instrumentation: `AddAspNetCoreInstrumentation()`, `AddEntityFrameworkCoreInstrumentation()`, `AddHttpClientInstrumentation()`
- Export: `AddOtlpExporter()` (LGTM stack)

## Logging

- Use **structured logging** with message templates: `_logger.LogInformation("Product {ProductId} created", id)`
- Never use string interpolation: `$"..."` loses structured data
- Use semantic property names that can be queried downstream

## Dependency Injection

- Constructor injection only
- **Max ~5 constructor parameters** — more indicates SRP violation, refactor
- Connection strings, secrets: always from `IConfiguration` (environment variables, not hardcoded)
- Register interfaces, inject abstractions (no concrete classes in constructors)

## Configuration (Options Pattern)

Use strongly-typed options instead of IConfiguration access scattered through code:
```csharp
public class SmtpSettings { public string Host { get; set; } }
builder.Services.Configure<SmtpSettings>(builder.Configuration.GetSection("Smtp"));
public class EmailService(IOptions<SmtpSettings> options) { }
```

## Code Style

- `#nullable enable` in all files (or `Directory.Build.props`)
- Implicit usings: enabled globally
- Records for DTOs, Commands, Queries
- `async/await` all the way — no `.Result` or `.Wait()`
- `CancellationToken` parameter on all async public methods

## Full Code Examples

For CQRS handlers, Minimal API endpoints, Result<T> class, EF Core config, OpenTelemetry setup, and DI examples, see `/dotnet-reference`
