# Phase 12 — Maintenance, Risks & Disaster Recovery Guide

This guide describes operational runbooks, backup rules, hazard classifications, and tech-debt management practices for the long-term maintenance of the Bike Rental Platform.

---

## 1. Technical Debt Management & Cleanup
To keep the system highly maintainable and prevent code decay over time, we focus on the following strategies:

- **Unused Library Audits**: Run monthly package audits using `go list -m all` and `flutter pub outdated` to prune dead dependencies, reducing security vulnerabilities and compilation size.
- **Code Duplication Pruning**: Ensure common layouts, helper functions, and shared types are migrated to the `/shared` directory rather than duplicated between the Customer and Owner mobile apps.
- **Refactoring Async Flow Models**: Continuously refactor callback-driven methods into modern async-await structures to keep code readable.

---

## 2. Risk Assessment Matrix

| Hazard Event | Severity | Probability | Mitigation Strategy | Action Plan |
|---|---|---|---|---|
| **Database Failure / Data Loss** | High | Low | Multi-AZ replication + hourly backups | Spin up fallback standby nodes and restore from the latest cold backup. |
| **API Denial of Service (DoS)** | Medium | Medium | Cloudflare protection + rate limiting | Enable aggressive edge filtering and adjust API rate limits. |
| **KYC Storage Leaks** | Critical | Low | Encrypted private buckets with timed SAS/pre-signed URLs | Audit cloud access policies, rotate storage access keys, and invalidate active sessions. |
| **Payment Webhook Failure** | High | Medium | Automatic webhook retry queue | Run a daily background job to reconcile missing transactions against the provider API. |

---

## 3. Database Backups & Recovery
To protect user and transaction data, we implement a strict automated backup strategy:

- **Automated Snaps**: Set up daily automated snapshots with a 30-day retention period.
- **Continuous Archiving (WAL)**: Enable Write-Ahead Logging (WAL) to support Point-in-Time Recovery (PITR), minimizing potential data loss.
- **Cold Storage Sync**: Encrypted backup archives are copied to an isolated, geographically separate cloud storage bucket.
- **Verification Drills**: Run monthly restore verification tests to confirm backup files are uncorrupted and ready to deploy in a disaster recovery scenario.

---

## 4. Rollback Strategies (Go-Live Safetynet)

### Go Backend
Our backend uses Docker image tags mapped to Git commits.
- **Action**: To roll back a broken release, update your production environment to target the previous stable image tag:
  ```bash
  docker compose set image backend=myregistry/bike-backend:v1.0.1-stable
  docker compose up -d --no-deps backend
  ```

### Flutter Applications
App stores do not support direct rollbacks of installed binaries.
- **Action**: To roll back, quickly compile and submit an updated release with an incremented version number (e.g., if `1.2.0` is broken, build `1.2.1` with the previous stable branch's code) and request an expedited review from Google.

---

## 5. Monitoring & Telemetry Architecture
Our monitoring system is designed to provide real-time operational visibility:

- **Health Checks**: The backend exposes a `/health` endpoint to monitor database connection states and API availability.
- **Metrics Logging**: Logs are formatted as JSON and printed directly to standard output, making them easy to ingest into log collectors (e.g., Promtail or Fluentbit).
- **Future Grafana Integration**: System metrics (CPU usage, memory consumption, request throughput, error rates) can be collected using Prometheus and visualized on Grafana dashboards for deep operational insights.
