terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
provider "digitalocean" {
  token = var.digitalocean_token
}

#provider "kubernetes" {
#  config_path    = "~/.kube/config"
#  config_context = "minikube"
#}
#
#provider "helm" {
#  kubernetes {
#    config_path = "~/.kube/config"
#  }
#}
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.default_cluster.endpoint
  token = digitalocean_kubernetes_cluster.default_cluster.kube_config.0.token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.default_cluster.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.default_cluster.endpoint
    token = digitalocean_kubernetes_cluster.default_cluster.kube_config.0.token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.default_cluster.kube_config.0.cluster_ca_certificate
    )
  }
}

resource "digitalocean_kubernetes_cluster" "default_cluster" {
  name    = var.cluster_name
  region  = var.region
  version = var.cluster_version
  node_pool {
    name       = "${var.cluster_name}-default-pool"
    size       = var.default_node_size
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}

