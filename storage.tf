resource "kubernetes_storage_class" "sc" {
  metadata {
    name = "paysera"
  }
  storage_provisioner = "k8s.io/minikube-hostpath"
  reclaim_policy      = "Retain"
}
