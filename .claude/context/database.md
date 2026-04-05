# Database & Migration Standards

## PostgreSQL Conventions

- Database: PostgreSQL 18 (default for all projects)
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

# Generate SQL script (for review or production)
dotnet ef migrations script --idempotent --project src/{Project}.Infrastructure
```

### Rules
- One migration per logical change — don't batch unrelated schema changes
- Migration names: `Add{Entity}Table`, `Add{Column}To{Table}`, `Remove{Column}From{Table}`
- Never edit a migration after it's been applied to any shared environment
- Use `IEntityTypeConfiguration<T>` for entity config — one file per entity
- Enable snake_case naming: `UseSnakeCaseNamingConvention()` via EFCore.NamingConventions
- Seed data: use `HasData()` in configuration for static reference data only
- Indexes: define in configuration, not via attributes

### Conflict Resolution
- If two branches add migrations with the same timestamp: delete the local one, re-create after merge
- Use `dotnet ef migrations list` to verify migration order

## Prisma (Next.js)

### Migration Workflow

```bash
# Development (creates + applies migration)
npx prisma migrate dev --name add_{entity}_table

# Production (applies pending migrations)
npx prisma migrate deploy

# Reset (destructive — dev only)
npx prisma migrate reset
```

### Rules
- Schema in `prisma/schema.prisma` — single source of truth
- Run `npx prisma generate` after schema changes to update client
- Use `@map` and `@@map` for snake_case table/column names
- Relations: always define both sides
- Singleton PrismaClient (globalThis pattern in Next.js)

## Drizzle (Astro)

### Migration Workflow

```bash
# Generate migration from schema changes
npx drizzle-kit generate

# Apply migrations
npx drizzle-kit migrate

# Push schema directly (dev only, no migration file)
npx drizzle-kit push
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
