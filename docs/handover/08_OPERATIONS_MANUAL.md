# Operations Manual

## Deployment
1.  **Environment Variables**: Create a `.env` in the `backend/` directory.
    *   `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `JWT_SECRET`.
2.  **Start Services**: `docker-compose up -d`
3.  **Reverse Proxy**: In production, deploy `NGINX` or `Traefik` in front of the Go API to handle SSL/TLS termination.

## Monitoring & Health Checks
*   **API Health**: Create a `GET /health` endpoint returning `200 OK`. Link this to uptime monitors (e.g., UptimeRobot, Datadog).
*   **Logging**: Logs are written to stdout via `Zap`. Aggregate these using ELK (Elasticsearch, Logstash, Kibana) or Grafana Loki.

## Rollback Procedure
*   If a deployment fails, revert the Docker image tag in `docker-compose.yml` to the previous stable version and run `docker-compose up -d`.
*   *Database Rollbacks*: Only run non-destructive database migrations (e.g., adding columns). Never drop columns or tables until fully deprecated.

## Incident Response
*   **Database Down**: Verify Docker container logs. Check disk space (`pgdata` volume).
*   **High API Latency**: Check `pg_stat_activity` for locked transactions or long-running queries. Add indexes if necessary.
