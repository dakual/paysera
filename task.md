# Practical Assignment – Site Reliability Engineer (SRE)

**Purpose**
Evaluate a candidate’s ability to design, provision, observe, and tune a stateful workload running on Kubernetes using Infrastructure‑as‑Code (IaC), scripting, and monitoring tooling.

**Expected effort**: ± 6–8 hours of focused work. **Hard deadline**: submit within 1 week after receiving the task.

---
## 1 · Environment prerequisites
* Linux/macOS workstation with **Docker**, **kubectl**, and either **Minikube ≥ v1.33** or **kind ≥ v0.22**.
* At least 8 GB RAM / 4 vCPU free.
* Ability to push to a public Git repository (GitHub/GitLab/Bitbucket).
* Kubernetes target version **v1.29.x**.

---
## 2 · Assignment steps
### 2.1 Bootstrap a reproducible local cluster
* Provide a single command (`make up`) that spins up Minikube/kind with load‑balancer support (e.g., MetalLB).
* A matching `make down` must fully destroy the cluster and artifacts.

### 2.2 Infrastructure as Code (IaC)
Use **Terraform, Pulumi, Ansible**, or a combination to declaratively manage:
1. Namespace(s)
2. StorageClass & PVCs
3. MetalLB (or alternative) load balancer
4. Helm release / K8s manifests for the database cluster

### 2.3 Deploy a highly‑available relational database
* Choose **PostgreSQL** or **MySQL**.
* Must run **≥ 3 replicas** with automatic fail‑over.
* Acceptable options: Bitnami PostgreSQL chart, Zalando PG Operator, MySQL InnoDB Cluster Operator, etc.
* Expose a service reachable from the host machine.

### 2.4 Seed the database with synthetic data
* Provide a **Go or Python** script (`make seed`) that creates ≥ 10 tables and inserts **≥ 1 million** rows in total.
* Use faker libraries for realistic values.
* Script must be **idempotent** and runnable from the host.

### 2.5 Performance & reliability testing
* Implement a repeatable benchmark (`make bench`) using **pgbench, sysbench, Locust,** or **JMeter**:
  * Duration: 5 minutes, configurable concurrency.
  * Capture TPS, average latency, p95/p99.
* Deploy **Prometheus + Grafana** in‑cluster to record CPU, memory, disk I/O.
* Define **two SLOs** (e.g., p99 < 200 ms, error rate < 0.1%) and verify them after the run.

### 2.6 Observability & alerting
* Export database metrics.
* Create at least **two PrometheusRule alerts** (e.g., replication lag > 5 s, disk usage > 80 %).
* Demonstrate an alert firing by triggering a condition and include a screenshot or log.

### 2.7 Documentation
* `README.md` covering: prerequisites, setup, architecture diagram, how to run seed & benchmarks, teardown.
* Explain sizing choices and tuning done to meet SLOs.

### 2.8 (⚡ Optional bonus)
* CI pipeline (GitHub Actions / GitLab CI) that stands up the cluster in Docker‑in‑Docker and runs smoke tests.
* Backup & restore demonstration.
* Horizontal Pod Autoscaler reacting to load.

---
## 3 · Deliverables
| Item | Description |
| --- | --- |
| Git repository | All IaC code, Helm values, scripts, dashboard JSON, and docs. |
| One‑command scripts | `make up`, `make seed`, `make bench`, `make down`. |
| Performance report | `performance‑report.md` (≤ 1 page) summarising results & bottlenecks. |
| Dashboards / snapshots | Exported Grafana JSON and/or screenshots. |

---
## 4 · Evaluation rubric (100 pts)
| Area | Points |
| --- | --- |
| Reproducibility (one‑command up/down) | **15** |
| IaC structure & code quality | **15** |
| Database cluster correctness & HA | **15** |
| Observability (metrics, dashboards, alerts) | **15** |
| Performance test design & results | **15** |
| Documentation & clarity | **15** |
| Bonus (CI, backup, HPA, etc.) | **10** |

---
## 5 · Submission instructions
1. Push to a public repository and send us the link.
2. Keep commit history tidy (squash where sensible).
3. We will test on a Linux laptop; if we cannot bootstrap in **≤ 30 min** the review stops.

---
## 6 · Support & rules
* Use only open‑source components license‑compatible with Apache 2.0.
* You may ask clarifying questions but we won’t provide debugging help.
* Do **not** rely on private container registries; either build locally or publish to Docker Hub public.
