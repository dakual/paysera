variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

locals {
  var = yamldecode(file("./workspaces/${terraform.workspace}.yaml"))
}
