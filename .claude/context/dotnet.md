# .NET Standards

## Solution Structure

```
src/
  {Project}.Domain/           # Entities, Value Objects, Repository interfaces
  {Project}.Application/      # Commands, Queries, Validators, DTOs
  {Project}.Core/             # Shared abstractions: ICommand, IQuery, Result<T>
  {Project}.Infrastructure/   # Handler implementations, external services
  {Project}.EntityFrameworkCore/  # DbContext, Migrations, EF config
  {Project}.Provider/         # ASP.NET Core host: Endpoints, Middleware, DI
```

Dependency flow: Domain ← Application ← Infrastructure ← Provider; Domain ← Core

## CQRS (No MediatR)

```csharp
// Application — Command + Validator
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

// Infrastructure — Handler
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

**Never throw business exceptions.** Return `Result<T>` from all handlers.

```csharp
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }

    private Result(bool isSuccess, T? value, string? error) { ... }

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
    group.MapGet("/{id:guid}", async (Guid id, IQueryHandler<...> handler, CancellationToken ct) =>
    {
        var result = await handler.Handle(new GetProductByIdQuery { Id = id }, ct);
        return result.IsSuccess ? Results.Ok(result.Value) : Results.NotFound();
    })
    .WithSummary("Get product by ID")
    .Produces<ProductDto>()
    .ProducesProblem(404);

    group.MapPost("/", async (CreateProductCommand command, ICommandHandler<...> handler, CancellationToken ct) =>
    {
        var result = await handler.Handle(command, ct);
        return result.IsSuccess
            ? Results.Created($"/api/products/{result.Value}", new { id = result.Value })
            : Results.BadRequest(new { error = result.Error });
    })
    .Produces<object>(201)
    .ProducesValidationProblem();

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
// ...
app.MapOpenApi();           // → /openapi/v1.json
app.MapScalarApiReference(); // → /scalar/v1
```

XML doc comments on all endpoints — required for TypeScript codegen.

## EF Core

- Code-first migrations only — never `EnsureCreated()` in production
- `UseSnakeCaseNamingConvention()` from `EFCore.NamingConventions`
- Entity config: `IEntityTypeConfiguration<T>` classes, not inline `OnModelCreating`
- Migration naming: `dotnet ef migrations add Add{Entity}Table`

## Package Management

```xml
<!-- Directory.Packages.props -->
<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
```

In `.csproj` files, omit versions: `<PackageReference Include="PackageName" />`

## Logging

```csharp
// ✅ Structured — queryable
_logger.LogInformation("Product {ProductId} created", product.Id);

// ❌ String interpolation — loses structured data
_logger.LogInformation($"Product {product.Id} created");
```

## Code Style

- `#nullable enable` in all files (or `Directory.Build.props`)
- Implicit usings enabled globally
- Records for DTOs, Commands, Queries
- `async/await` all the way — no `.Result` or `.Wait()`
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
