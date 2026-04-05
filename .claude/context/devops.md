# DevOps & Infrastructure Standards

## Docker

- Centralized infra: `~/workspace/docker/` — shared Docker Compose (PostgreSQL 18, Grafana LGTM stack)
- Project-level `docker-compose.yml` for local development; use centralized stack for shared services
- Never hardcode credentials — use `.env` files (never committed) with `.env.example` committed
- Multi-stage builds for production images (build → publish → runtime)
- Pin base image versions (e.g. `mcr.microsoft.com/dotnet/aspnet:10.0-alpine`)
- Health checks on all services

## Kubernetes

- Configs at `~/workspace/k8s/`
- Resources: Deployment, Service, Ingress, ConfigMap, Secret
- Secrets managed externally (never committed to git)
- Resource limits and requests defined on all containers
- Liveness + readiness probes on all pods
- Use namespaces for environment isolation (dev, staging, prod)

## Grafana LGTM Stack (Observability)

- **Loki**: logs | **Grafana**: dashboards | **Tempo**: traces | **Mimir**: metrics
- .NET apps: `AddOtlpExporter()` to ship telemetry
- OTLP endpoint: configured per environment via env vars
- Structured logging (JSON) — no unstructured console output in production

## General Rules

- Infrastructure as code — all config in files, nothing manual
- Idempotent operations — running twice produces same result
- Environment parity — dev should mirror production as closely as possible
- Tag images with git SHA or semver, never `latest` in production
