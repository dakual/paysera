resource "kubernetes_namespace" "paysera" {
  metadata {
    name = local.var.namespace
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}