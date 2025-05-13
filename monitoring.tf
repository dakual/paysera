resource "helm_release" "prometheus" {
  chart         = "prometheus"
  name          = "prometheus"
  namespace     = kubernetes_namespace.monitoring.metadata.0.name
  repository    = "https://prometheus-community.github.io/helm-charts"
  version       = "18.1.0"
  wait          = true
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/configs/prometheus.yml", {
      persistence_volume = true
    }),
    file("${path.module}/configs/alertmanager.yml"),
    file("${path.module}/configs/alerting_rules.yml")
  ]
 
  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}


resource "helm_release" "grafana" {
  chart         = "grafana"
  name          = "grafana"
  repository    = "https://grafana.github.io/helm-charts"
  namespace     = kubernetes_namespace.monitoring.metadata.0.name
  version       = "9.0.0"
  wait          = true
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/configs/grafana.yaml", {
      prometheus_svc = "${helm_release.prometheus.name}-server"
    })
  ]

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubernetes_config_map" "grafana_dashboard" {
  metadata {
    name      = "grafana-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "custom-dashboard.json" = file("${path.module}/dashboards/postgresql.json")
  }
}
