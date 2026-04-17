---
name: dotnet
description: This skill should be used when the user asks to "write .NET code", "create a command handler", "add an endpoint", "configure EF Core", "set up CQRS", "use Result pattern", or works on .NET 10 / ASP.NET Core / Minimal API / Entity Framework Core projects (qoommerce, qretna, loodos a101-mep-backend).
version: 1.0.0
---

# .NET 10 Backend Standards

Apply when implementing .NET 10 + ASP.NET Core + EF Core + PostgreSQL backends following Clean Architecture and CQRS without MediatR.

## Solution Structure

```
src/
  {Project}.Domain/                # Entities, Value Objects, Repository interfaces
  {Project}.Application/           # Commands, Queries, Validators, DTOs
  {Project}.Core/                  # Shared abstractions: ICommand, IQuery, Result<T>
  {Project}.Infrastructure/        # Handler implementations, external services
  {Project}.EntityFrameworkCore/   # DbContext, Migrations, EF config
  {Project}.Provider/              # ASP.NET Core host: Endpoints, Middleware, DI
```

Dependency flow: Domain ← Application ← Infrastructure ← Provider; Domain ← Core

## CQRS (No MediatR)

Define handlers explicitly with `ICommandHandler<TCommand, TResult>` / `IQueryHandler<TQuery, TResult>` abstractions in `{Project}.Core`.

```csharp
public record CreateProductCommand : ICommand<Result<Guid>>
{
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
}

public class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Price).GreaterThan(0);
    }
}

public class CreateProductCommandHandler : ICommandHandler<CreateProductCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateProductCommand command, CancellationToken ct = default)
    {
        var product = Product.Create(command.Name, command.Price);
        await _repository.AddAsync(product, ct);
        await _unitOfWork.SaveChangesAsync(ct);
        return Result<Guid>.Success(product.Id);
    }
}
```

## Result Pattern

Never throw business exceptions. Return `Result<T>` from all handlers. Reserve exceptions for unrecoverable infrastructure failures.

```csharp
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }

    public static Result<T> Success(T value) => new(true, value, null);
    public static Result<T> Failure(string error) => new(false, default, error);
}
```

## Minimal API Endpoints (No Controllers)

```csharp
public static IEndpointRouteBuilder MapProductEndpoints(this IEndpointRouteBuilder app)
{
    var group = app.MapGroup("/api/products").WithTags("Products");

    /// <summary>Get product by ID</summary>
    group.MapGet("/{id:guid}", async (Guid id, IQueryHandler<GetProductByIdQuery, Result<ProductDto>> handler, CancellationToken ct) =>
    {
        var result = await handler.Handle(new GetProductByIdQuery { Id = id }, ct);
        return result.IsSuccess ? Results.Ok(result.Value) : Results.NotFound();
    })
    .WithSummary("Get product by ID")
    .Produces<ProductDto>()
    .ProducesProblem(404);

    return app;
}
```

## HTTP Status Codes

| Scenario | Code |
|----------|------|
| Success with data | 200 OK |
| Resource created | 201 Created |
| Success no data | 204 NoContent |
| Validation error | 400 BadRequest |
| Unauthorized | 401 |
| Forbidden | 403 |
| Not found | 404 |
| Conflict | 409 |

## OpenAPI / Scalar (Mandatory)

```csharp
builder.Services.AddOpenApi();
app.MapOpenApi();             // → /openapi/v1.json
app.MapScalarApiReference();  // → /scalar/v1
```

XML doc comments on every endpoint — required for TypeScript codegen on the frontend (see `api-contract` skill).

## EF Core

- Code-first migrations only — never `EnsureCreated()` in production
- `UseSnakeCaseNamingConvention()` from `EFCore.NamingConventions`
- Entity config: `IEntityTypeConfiguration<T>` classes, not inline `OnModelCreating`
- Migration naming: `dotnet ef migrations add Add{Entity}Table`

See `database` skill for migration workflow and PostgreSQL conventions.

## Package Management

Centralize versions in `Directory.Packages.props`:

```xml
<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
```

In `.csproj`, omit versions: `<PackageReference Include="PackageName" />`.

## Logging

```csharp
// ✅ Structured — queryable
_logger.LogInformation("Product {ProductId} created", product.Id);

// ❌ Loses structured data
_logger.LogInformation($"Product {product.Id} created");
```

## Code Style

- `#nullable enable` in all files (or `Directory.Build.props`)
- Implicit usings enabled globally
- Records for DTOs, Commands, Queries
- `async/await` all the way — never `.Result` or `.Wait()`
- `CancellationToken` on all async public methods
- Max ~5 constructor parameters — more indicates SRP violation

## Observability

```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(t => t
        .AddAspNetCoreInstrumentation()
        .AddEntityFrameworkCoreInstrumentation()
        .AddOtlpExporter())
    .WithMetrics(m => m
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter());
```

Ship to Grafana LGTM stack — see `devops` skill.

## Companion Skills

- `database` — PostgreSQL conventions, EF Core migration workflow
- `api-contract` — OpenAPI ↔ TypeScript codegen
- `security` — auth, validation, error handling
- `testing` — xUnit, FluentAssertions, integration tests
- `commits` — conventional commit format
