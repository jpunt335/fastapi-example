terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.21.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

#provider "kubernetes" {
#  host = digitalocean_kubernetes_cluster.default_cluster.endpoint
#  cluster_ca_certificate = base64decode(
#    digitalocean_kubernetes_cluster.default_cluster.kube_config.0.cluster_ca_certificate
#  )
#
#  exec {
#    api_version = "client.authentication.k8s.io/v1beta1"
#    command = "doctl"
#    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
#    "--version=v1beta1", digitalocean_kubernetes_cluster.default_cluster.id]
#  }
#}