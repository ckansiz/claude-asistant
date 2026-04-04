# /devops — DevOps / Infra Mode

Standards to apply for this session:

## Docker
- `~/workspace/docker/` — centralized Docker Compose infra (PostgreSQL 18, Grafana LGTM stack)
- Project-level `docker-compose.yml` for local development; use centralized stack for shared services
- Never hardcode credentials — use `.env` files (never committed) with `.env.example` committed

## Kubernetes
- Configs at `~/workspace/k8s/`
- Resources: Deployment, Service, Ingress, ConfigMap, Secret
- Secrets managed externally (never committed to git)
- Resource limits defined on all containers

## Grafana LGTM Stack (Observability)
- **Loki**: logs | **Grafana**: dashboards | **Tempo**: traces | **Mimir**: metrics
- .NET apps: `AddOtlpExporter()` to ship telemetry
- OTLP endpoint: configured per environment via env vars

## General Rules
- Infrastructure as code — all config in files, nothing manual
- Idempotent operations — running twice produces same result
- Health checks on all services
- Read `.claude/context/commits.md` for commit conventions

Delegate implementation to **@builder**.

$ARGUMENTS
