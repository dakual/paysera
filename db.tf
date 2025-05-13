resource "helm_release" "db" {
  chart         = "postgresql-ha"
  name          = "paysera"
  namespace     = local.var.namespace
  repository    = "oci://registry-1.docker.io/bitnamicharts"
  version       = "16.0.3"
  wait          = true
  wait_for_jobs = true

  values = [yamlencode(local.var.database)]

  depends_on = [
    kubernetes_namespace.paysera,
  ]
}