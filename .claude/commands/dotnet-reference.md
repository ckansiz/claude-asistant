# .NET Code Examples & Patterns Reference

Use this when you need exact code patterns for .NET 10 CQRS implementation.

## CQRS Handlers

### Command Pattern

```csharp
// Application layer — Command definition + Validator
public record CreateProductCommand : ICommand<Result<Guid>>
{
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
    public string CategoryId { get; init; } = string.Empty;
}

public class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Price).GreaterThan(0);
        RuleFor(x => x.CategoryId).NotEmpty();
    }
}

// Infrastructure layer — Handler implementation
public class CreateProductCommandHandler : ICommandHandler<CreateProductCommand, Result<Guid>>
{
    private readonly IProductRepository _repository;
    private readonly IUnitOfWork _unitOfWork;

    public CreateProductCommandHandler(IProductRepository repository, IUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<Guid>> Handle(CreateProductCommand command, CancellationToken cancellationToken = default)
    {
        var product = Product.Create(command.Name, command.Price, command.CategoryId);
        await _repository.AddAsync(product, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(product.Id);
    }
}
```

### Query Pattern

```csharp
// Application layer
public record GetProductByIdQuery : IQuery<Result<ProductDto>>
{
    public Guid Id { get; init; }
}

// Infrastructure layer
public class GetProductByIdQueryHandler : IQueryHandler<GetProductByIdQuery, Result<ProductDto>>
{
    private readonly IProductRepository _repository;

    public GetProductByIdQueryHandler(IProductRepository repository)
    {
        _repository = repository;
    }

    public async Task<Result<ProductDto>> Handle(GetProductByIdQuery query, CancellationToken cancellationToken = default)
    {
        var product = await _repository.GetByIdAsync(query.Id, cancellationToken);
        if (product is null) return Result<ProductDto>.Failure("Product not found");
        return Result<ProductDto>.Success(ProductDto.FromDomain(product));
    }
}
```

## Result<T> Pattern

Never throw business exceptions. Return `Result<T>` from all handlers.

```csharp
// Core layer
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }

    private Result(bool isSuccess, T? value, string? error)
    {
        IsSuccess = isSuccess;
        Value = value;
        Error = error;
    }

    public static Result<T> Success(T value) => new(true, value, null);
    public static Result<T> Failure(string error) => new(false, default, error);
}
```

## Minimal API Endpoints

```csharp
// Provider/Endpoints/ProductEndpoints.cs
public static class ProductEndpoints
{
    public static IEndpointRouteBuilder MapProductEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/products")
            .WithTags("Products")
            .RequireAuthorization();

        /// <summary>Get product by ID</summary>
        group.MapGet("/{id:guid}", async (
            Guid id,
            IQueryHandler<GetProductByIdQuery, Result<ProductDto>> handler,
            CancellationToken ct) =>
        {
            var result = await handler.Handle(new GetProductByIdQuery { Id = id }, ct);
            return result.IsSuccess ? Results.Ok(result.Value) : Results.NotFound(new { error = result.Error });
        })
        .WithSummary("Get product by ID")
        .Produces<ProductDto>()
        .ProducesProblem(404);

        /// <summary>Create a new product</summary>
        group.MapPost("/", async (
            CreateProductCommand command,
            ICommandHandler<CreateProductCommand, Result<Guid>> handler,
            CancellationToken ct) =>
        {
            var result = await handler.Handle(command, ct);
            return result.IsSuccess
                ? Results.Created($"/api/products/{result.Value}", new { id = result.Value })
                : Results.BadRequest(new { error = result.Error });
        })
        .WithSummary("Create a new product")
        .Produces<object>(201)
        .ProducesValidationProblem();

        return app;
    }
}
```

## HTTP Status Codes

| Scenario | Code |
|----------|------|
| Success with data | 200 OK |
| Resource created | 201 Created (+ Location header) |
| Success no data | 204 NoContent |
| Validation error | 400 BadRequest |
| Unauthorized | 401 Unauthorized |
| Forbidden | 403 Forbidden |
| Not found | 404 NotFound |
| Conflict (duplicate) | 409 Conflict |

## EF Core DbContext

```csharp
// EntityFrameworkCore layer
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Product> Products => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
        // NamingConventions — snake_case column names
    }
}
```

## Package Management (Directory.Packages.props)

```xml
<!-- Directory.Packages.props (solution root) -->
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Microsoft.EntityFrameworkCore" Version="10.0.1" />
    <PackageVersion Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="10.0.0" />
    <PackageVersion Include="FluentValidation.DependencyInjectionExtensions" Version="12.1.1" />
  </ItemGroup>
</Project>
```

In `.csproj` files, omit versions:
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore" />
```

## OpenAPI Configuration

```csharp
// Program.cs
builder.Services.AddOpenApi();

// ...

app.MapOpenApi(); // serves /openapi/v1.json
app.MapScalarApiReference(); // serves /scalar/v1
```

XML doc comments on all endpoints (required for generated TypeScript types):

```csharp
/// <summary>Get a product by its ID</summary>
/// <param name="id">The product GUID</param>
group.MapGet("/{id:guid}", async (Guid id, ...) => { ... })
    .WithSummary("Get product by ID")
    .Produces<ProductDto>(200)
    .ProducesProblem(404);
```

## Observability (OpenTelemetry)

```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddEntityFrameworkCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddOtlpExporter())
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter());
```

## Structured Logging

```csharp
// ✅ Structured logging with message templates
_logger.LogInformation("Product {ProductId} created by user {UserId}", product.Id, userId);

// ❌ String interpolation — loses structured data
_logger.LogInformation($"Product {product.Id} created");
```

## Dependency Injection Best Practices

```csharp
// ✅ Constructor injection
private readonly IProductRepository _repository;
private readonly IUnitOfWork _unitOfWork;
private readonly ILogger<CreateProductCommandHandler> _logger;

// ❌ Too many dependencies — refactor needed
private readonly IRepo1 _r1;
private readonly IRepo2 _r2;
private readonly IService1 _s1;
private readonly IService2 _s2;
private readonly IService3 _s3;
private readonly IService4 _s4;
private readonly ILogger<X> _logger;
```

Max ~5 constructor parameters. More indicates SRP violation.

## Configuration (Options Pattern)

```csharp
// Options pattern for typed configuration
public class SmtpSettings
{
    public string Host { get; set; } = string.Empty;
    public int Port { get; set; }
}

// Registration
builder.Services.Configure<SmtpSettings>(
    builder.Configuration.GetSection("Smtp"));

// Usage
public class EmailService(IOptions<SmtpSettings> options) { }
```
