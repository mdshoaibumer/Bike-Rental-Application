# Knowledge Transfer & Handover Plan — Bike Rental Platform

This document outlines the training topics, codebase walkthroughs, and operational responsibilities needed to successfully hand over the project to a new development or operations team.

---

## 1. Technical Training Curriculum

To help incoming engineers get up to speed quickly, we recommend a 5-day structured walkthrough of the codebase:

```
┌────────────────────────────────────────────────────────┐
│               5-DAY HANDOVER CURRICULUM                │
├───────┬────────────────────────────────────────────────┤
│ Day 1 │ Architecture Walkthrough & Go DDD Overview     │
├───────┼────────────────────────────────────────────────┤
│ Day 2 │ Database Models, Constraints & Transactions     │
├───────┼────────────────────────────────────────────────┤
│ Day 3 │ Flutter Monorepo, Shared Styling & Riverpod    │
├───────┼────────────────────────────────────────────────┤
│ Day 4 │ Security, JWT Rules & Webhook Configurations   │
├───────┼────────────────────────────────────────────────┤
│ Day 5 │ Docker Configurations, CI/CD Pipelines & cloud │
└───────┴────────────────────────────────────────────────┘
```

### Day 1: Architecture Walkthrough & Go DDD Overview
- **Session Goals**: Introduce the directory layout, package boundaries, and dependency flow of the Go backend.
- **Key Concepts**: Domain entity isolation, service layers, mapping handlers, and the application composition root in `cmd/api/main.go`.

### Day 2: Database Models, Constraints & Transactions
- **Session Goals**: Review the database schema, indexing strategies, and date overlap verification constraints.
- **Key Concepts**: Database pooling configurations (`SetMaxOpenConns`), date-overlap queries, and cascading deletion rules.

### Day 3: Flutter Monorepo & Client Applications
- **Session Goals**: Walk through compiling the apps, editing code in `/shared`, and managing state with Riverpod.
- **Key Concepts**: Responsive widget structures, image loading, client-side offline storage, and navigation routing.

### Day 4: Security, JWT Rules & Webhook Configurations
- **Session Goals**: Learn how the platform manages user roles (RBAC) and secures communication with external payment gateways.
- **Key Concepts**: JWT validation middleware, secure token storage, and webhook signature verification.

### Day 5: Docker Configurations, CI/CD Pipelines & Cloud Operations
- **Session Goals**: Deploy the services, monitor logs, and configure CI/CD delivery pipelines.
- **Key Concepts**: Multi-stage Docker optimization, GitHub Actions release pipelines, Nginx configurations, and DB snapshot schedules.

---

## 2. Key Maintenance Responsibilities

Following handover, the operations team should manage the following ongoing tasks:

1. **Regular Dependency Audits**
   - Check for and update vulnerable libraries in Go and Flutter on a monthly basis.
2. **Monitor Error Rates**
   - Track HTTP 5xx responses and client-side crash logs to catch and resolve runtime exceptions.
3. **Validate Database Snaps**
   - Perform scheduled dry-run recovery drills to verify backup files are healthy.
4. **Certificate Renewals**
   - Set up automated Let's Encrypt cron jobs to renew HTTPS certificates every 90 days.
