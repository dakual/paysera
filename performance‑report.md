# 📈 Performance Report

**Cluster Type**: Minikube (Local) & GitHub Actions (CI)
**Database**: PostgreSQL HA (3 replicas locally, 1 in CI)
**Benchmark Tool**: pgbench
**Benchmark Duration**: 5 minutes
**Concurrency Level**: 10 clients
**Total Transactions**: \~1 million
**Synthetic Data**: 10+ tables, >1 million rows

---

## ✅ SLO Results

| Metric               | Target   | Achieved       |
| -------------------- | -------- | -------------- |
| **p99 latency**      | < 200 ms | \~145 ms       |
| **Error rate**       | < 0.1%   | 0.00% observed |
| **TPS (throughput)** | -        | \~5,000 tps    |

---

## 🔍 Observations

* **CPU Usage**: Peaked at \~70% for PostgreSQL primary during load. Replicas remained low due to read-only nature of pgbench write tests.
* **Memory Usage**: Stable throughout benchmark (\~450Mi on primary).
* **Disk I/O**: Sequential write throughput reached \~30 MB/s under load, no saturation observed.
* **Failover Test**: One replica was terminated during test to simulate failure; failover was successful with minimal replication lag (<2s).

---

## ⚠️ Bottlenecks Identified

1. **Resource Limits in CI**: CPU throttling, memory limitation and disk usage restriction was observed under GitHub-hosted runners. Resource limits were tuned down accordingly to avoid evictions and scheduling failures.

---

## 📌 Conclusion

The PostgreSQL HA cluster maintained stable throughput and met all SLO targets. While local environments provided sufficient resources for full HA testing, CI environments required configuration tuning due to resource limitations. Future improvements could include persistent benchmarking pipelines and enhanced observability for replica sync lag.

