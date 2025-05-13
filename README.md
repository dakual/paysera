# 🚀 Site Reliability Engineer Practical Assignment

## 📌 Overview

This project is a complete implementation of a high-availability PostgreSQL deployment on Kubernetes using Infrastructure-as-Code and automation. It fulfills all requirements from cluster provisioning to observability, benchmarking, and optional bonus features.

---

## 📋 Prerequisites

Before getting started, ensure the following tools are installed on your local machine:

* [Docker](https://www.docker.com/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Minikube](https://minikube.sigs.k8s.io/docs/)
* [Terraform](https://www.terraform.io/)
* [Helm](https://helm.sh/)
* Python 3.10+ (for data seeding)
* `make`

Minimum system requirements:

* 8 GB RAM
* 4 vCPU free

---

## ⚙️ Setup Instructions

### 1. Start the cluster with Minikube

```bash
make up
```

This command:

* Starts a Minikube cluster with 4 GB memory and 2 CPU cores
* Enables MetalLB addon for LoadBalancer support

### 2. Deploy terraform

```bash
make tf-apply
```

This command:

* Applies Terraform manifests
* Installs PostgreSQL HA cluster via Helm
* Deploys Prometheus, Grafana, and Alertmanager
* Add Postgres Grafana dashboard

### 2. Expose Services to Host

```bash
make expose
```

Exposes the following services via `minikube service`:

* PostgreSQL
* Prometheus
* Grafana
* Alertmanager

### 3. Seed the PostgreSQL database with synthetic data

* Note: before run `make seed` you need to run first `make expose`

```bash
make seed
```

This script:

* Creates 10+ tables
* Inserts over 1 million rows using `faker`
* Is idempotent and safely re-runnable

### 4. Run Performance Benchmarks

* Note: before run `make seed` you need to run first `make expose`

```bash
make bench
```

This command:

* Initializes `pgbench`
* Runs a 5-minute performance test with configurable concurrency
* Outputs TPS, average latency, and p95/p99 metrics

### 5. Backup Database

```bash
make backup
```

This command:

* Dumps all PostgreSQL databases into `backup.sql`

### 6. Restore Database

```bash
make restore
```

This command:

* Restore PostgreSQL databases from `backup.sql`

---

## 📁 Directory Structure Highlights

* `configs/`: Contains configuration files for Prometheus, Grafana, and Alertmanager.
* `exporter/`: Contains both a `pg-exporter` manifest and a Helm chart. While these components are functional, they were not used. Instead, the native `postgres-exporter` provided within the `postgresql-ha` Helm chart was utilized.
* `k8s/`: Includes the Horizontal Pod Autoscaler (HPA) manifest. HPA is only deployed for the Grafana component.
* `workspaces/`: Includes Terraform workspace configuration files. For example:

  * When working locally, it uses `default.yaml`.
  * When running in GitHub Actions, it uses `github.yaml`, which includes reduced replica count for PostgreSQL to accommodate GitHub runner resource limitations.

---

## 📉 Observability & Monitoring

The cluster includes:

* Prometheus for metrics collection
* Grafana for dashboards (auto-loaded from `dashboard.json`)
* Alertmanager with alerts:

  * Replication lag > 5s
  * Disk usage > 80%

You can validate them via Grafana dashboards and Prometheus queries.

---

## 🧹 Teardown

To clean up all cluster resources:

```bash
make down
```

This command:

* Destroys the Minikube cluster

To remove only Terraform-managed resources:

```bash
make tf-destroy
```

---

## 🗂️ Architecture Diagram

```
┌──────────────────────────────────────────────────────┐
│                Local Kubernetes Cluster              │
│  ┌───────────────┐      ┌────────────┐               │
│  │ PostgreSQL HA │◄────►│ LoadBalancer│               │
│  └─────▲────▲────┘      └────────────┘               │
│        │    │                                        │
│  ┌─────┴────┴─────┐                                  │
│  │ Prometheus     │◄────── Metrics Exporters         │
│  └─────▲──────────┘                                  │
│        │                                             │
│  ┌─────┴───────┐                                     │
│  │ Grafana     │◄────── Dashboards, Alerts           │
│  └─────────────┘                                     │
└──────────────────────────────────────────────────────┘
```

---

## 📦 Deliverables Summary

| Item                | Status           |
| ------------------- | ---------------- |
| Minikube Setup      | ✅ `make up`      |
| Terraform IaC       | ✅                |
| PostgreSQL HA       | ✅                |
| Data Seeding        | ✅ `make seed`    |
| Benchmarks          | ✅ `make bench`   |
| Monitoring + Alerts | ✅                |
| Teardown            | ✅ `make down`    |
| CI/CD (Bonus)       | ✅ GitHub Actions |
| Backup & Restore    | ✅                |
| HPA (Bonus)         | ✅ for the grafana|

---

