# Testing Standards

## .NET (xUnit + FluentAssertions)

### Structure
- Test project per source project: `{Project}.Tests/`
- Naming: `{ClassName}Tests.cs` → `{MethodName}_Should_{ExpectedBehavior}`
- Arrange-Act-Assert pattern, one assertion concept per test

### What to test
- Command/query handlers (business logic)
- Domain entity methods and validation
- Endpoint integration tests (WebApplicationFactory)
- EF Core queries against real PostgreSQL (Testcontainers)

### What NOT to test
- Framework code (EF Core, ASP.NET plumbing)
- Private methods directly
- Trivial mappings (DTO → entity if using AutoMapper/Mapster)

### Packages
- `xUnit` — test framework
- `FluentAssertions` — readable assertions
- `NSubstitute` — mocking
- `Testcontainers.PostgreSql` — real DB for integration tests
- `Microsoft.AspNetCore.Mvc.Testing` — WebApplicationFactory

### Example
```csharp
public class CreateOrderHandlerTests
{
    [Fact]
    public async Task Handle_Should_ReturnSuccess_WhenOrderIsValid()
    {
        // Arrange
        var handler = new CreateOrderHandler(dbContext);
        var command = new CreateOrderCommand { /* ... */ };

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
    }
}
```

## Astro / Next.js (Vitest)

### Structure
- Test files next to source: `component.test.ts` or `__tests__/` directory
- Naming: `describe('{Component}')` → `it('should {behavior}')`

### What to test
- Utility functions and helpers
- API route handlers (request/response)
- React component behavior (Testing Library)
- Form validation logic (Zod schemas)

### Packages
- `vitest` — test runner (compatible with Vite/Astro)
- `@testing-library/react` — component testing
- `@testing-library/user-event` — user interaction simulation
- `msw` — API mocking (Mock Service Worker)

### Config
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
  },
})
```

## React Native (Jest + RNTL)

### Structure
- Test files: `__tests__/{Component}.test.tsx`
- Naming: same as web (describe/it pattern)

### Packages
- `jest` — test runner (Expo default)
- `@testing-library/react-native` — component testing
- `msw` — API mocking

### What to test
- Screen rendering and navigation
- User interactions (press, type, scroll)
- Zustand store logic
- API hooks (TanStack Query with msw)

## General Rules

- Tests run in CI — broken tests block merge
- No `test.skip` or `test.todo` in committed code without a linked issue
- Prefer integration tests over unit tests for API endpoints
- Mock external services (APIs, email), never mock the database in integration tests
- Test error paths, not just happy paths
