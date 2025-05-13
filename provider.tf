terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }
}

provider "kubernetes" {
  config_context_cluster = "paysera"
  config_path            = pathexpand(var.kube_config)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

provider "kubectl" {
  config_context_cluster = "paysera"
  config_path            = pathexpand(var.kube_config)
}