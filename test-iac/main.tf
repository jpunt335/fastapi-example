terraform {

  required_providers {

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.27.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }

  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

 #Configure kubernetes provider
provider "kubernetes" {
  host = digitalocean_kubernetes_cluster.k8s-cluster.endpoint
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.k8s-cluster.kube_config.0.cluster_ca_certificate
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", digitalocean_kubernetes_cluster.k8s-cluster.id]
  }
}

 #Configure the helm Provider
provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.k8s-cluster.endpoint
    token = digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

# Link the domain
resource "digitalocean_domain" "weerwijzer-online" {
  name       = var.domain_name
}

# Add an A record to the domain for weerwijzer-belastingdienst.online
resource "digitalocean_record" "main_record" {
  depends_on = [data.kubernetes_service_v1.ingress_svc]
  domain = digitalocean_domain.weerwijzer-online.id
  type   = "A"
  name   = "@"
  value  = data.kubernetes_service_v1.ingress_svc.status.0.load_balancer.0.ingress.0.ip
}

resource "digitalocean_kubernetes_cluster" "k8s-cluster" {
  name   = var.cluster_name
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = var.k8s_version

  node_pool {
    name       = "worker-pool"
    size       = var.node_size
    node_count = var.node_count

  }
  registry_integration = true
}

resource "digitalocean_loadbalancer" "ingress_load_balancer" {
  name   = "${var.cluster_name}-lb"
  region = var.region
  size = "lb-small"
  algorithm = "round_robin"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"

  }

  lifecycle {
      ignore_changes = [
        forwarding_rule,
    ]
  }

}
# make postgres volumes?
#resource "helm_release" "postgres" {
#  depends_on = [digitalocean_kubernetes_cluster.k8s-cluster]
#
#  name       = "postgres"
#  repository = "https://charts.bitnami.com/bitnami"
#  chart      = "postgresql-ha"
#
#  values = ["${file("values.yml")}"]
#}


# Create a managed database
resource "digitalocean_database_cluster" "mysql" {
  name       = "weerwijzer-db"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = "ams3"
  node_count = 1
}


# Create a new container registry
resource "digitalocean_container_registry" "container-do" {
  name                   = "weerwijzer-container"
  subscription_tier_slug = "starter"
  region = var.region
}

# cert-manager resources

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.0.1"
  namespace        = "kube-system"
  timeout          = 120
  depends_on = [
    kubernetes_ingress.k8s-cluster_ingress,
  ]
  set {
    name  = "createCustomResource"
    value = "true"
  }
  set {
    name = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "cluster-issuer" {
  name      = "cluster-issuer"
  chart     = "../helm_charts/cluster-issuer"
  namespace = "kube-system"
  depends_on = [
    helm_release.cert-manager,
  ]
  set {
    name  = "letsencrypt_email"
    value = "${var.letsencrypt_email}"
  }
}

resource "kubernetes_deployment" "sample_deployments" {
  for_each = toset(var.domain_name)
  metadata {
    name = "${replace(each.value, ".", "-")}-deployment"
    namespace="default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "${replace(each.value, ".", "-")}-deployment"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${replace(each.value, ".", "-")}-deployment"
        }
      }
      spec {
        container {
          image = "my-python-app"
          name  = "weerwijzer-container"
          port {
            container_port = 80
          }
          resources {
            limits = {
              memory = "512M"
              cpu = "1"
            }
            requests = {
              memory = "256M"
              cpu = "50m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "sample_services" {
  for_each = toset(var.domain_name)
  metadata {
    name      = "${replace(each.value, ".", "-")}-service"
    namespace = "default"
  }
  spec {
    selector = {
      app = "${replace(each.value, ".", "-")}-deployment"
    }
    port {
      port = 80
    }
  }
}

data "kubernetes_service_v1" "ingress_svc" {
  depends_on = [helm_release.nginx_ingress]
  metadata {
    name = var.nginx_svc_name
  }
}



output "my-kube-config" {
  value = digitalocean_kubernetes_cluster.k8s-cluster.kube_config.0.raw_config
  sensitive = true
}


#data "digitalocean_ssh_key" "my_key" {
#  name = "Justin"
#}


