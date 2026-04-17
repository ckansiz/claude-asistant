---
name: database
description: This skill should be used when the user asks to "create a migration", "modify a database schema", "add a table", "update Drizzle/Prisma/EF Core schema", or works on PostgreSQL data models.
version: 1.0.0
---

# Database & Migration Standards

Apply when modifying database schemas with EF Core (.NET), Prisma (Next.js), or Drizzle (Astro). Default DB: PostgreSQL 18.

## PostgreSQL Conventions

- Naming: `snake_case` for tables, columns, indexes, constraints
- Table names: plural (`orders`, `order_items`)
- Primary keys: `id` (UUID or serial, project decides)
- Foreign keys: `{referenced_table_singular}_id` (e.g. `order_id`)
- Indexes: `ix_{table}_{columns}` (e.g. `ix_orders_customer_id`)
- Unique constraints: `uq_{table}_{columns}`
- Timestamps: `created_at`, `updated_at` (UTC, `timestamptz`)

## EF Core (.NET)

### Migration Workflow

```bash
# Create migration
dotnet ef migrations add Add{Entity}Table --project src/{Project}.Infrastructure

# Apply to local DB
dotnet ef database update --project src/{Project}.Infrastructure

# Generate SQL script (review or production)
dotnet ef migrations script --idempotent --project src/{Project}.Infrastructure
```

### Rules
- One migration per logical change — never batch unrelated schema changes
- Migration names: `Add{Entity}Table`, `Add{Column}To{Table}`, `Remove{Column}From{Table}`
- Never edit a migration after applying to any shared environment
- Use `IEntityTypeConfiguration<T>` for entity config — one file per entity
- Enable snake_case naming: `UseSnakeCaseNamingConvention()` via `EFCore.NamingConventions`
- Seed data: use `HasData()` in configuration for static reference data only
- Indexes: define in configuration, not via attributes

### Conflict Resolution
- Two branches with same migration timestamp: delete the local one, re-create after merge
- Use `dotnet ef migrations list` to verify migration order

## Prisma (Next.js)

### Migration Workflow

```bash
npx prisma migrate dev --name add_{entity}_table   # Dev (creates + applies)
npx prisma migrate deploy                          # Production (apply pending)
npx prisma migrate reset                           # Reset (destructive — dev only)
```

### Rules
- Schema in `prisma/schema.prisma` — single source of truth
- Run `npx prisma generate` after schema changes
- Use `@map` and `@@map` for snake_case table/column names
- Relations: always define both sides
- Singleton PrismaClient (globalThis pattern in Next.js)

## Drizzle (Astro)

### Migration Workflow

```bash
npx drizzle-kit generate    # Generate migration from schema changes
npx drizzle-kit migrate     # Apply migrations
npx drizzle-kit push        # Push schema directly (dev only, no migration file)
```

### Rules
- Schema in `src/lib/db/schema.ts`
- Use `pgTable()` with explicit column definitions
- snake_case column names by default
- Relations defined via `relations()` helper

## General Rules

- Never drop columns/tables in production without a deprecation period
- Destructive migrations: rename → copy → drop (over multiple deploys)
- Always test migrations against a copy of production data before deploying
- Back up before running migrations in production
- Keep migrations small and reversible where possible
