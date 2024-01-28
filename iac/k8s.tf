resource "kubernetes_namespace" "example" {
  metadata {
    name = "novi-k8s"
  }
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "fastapi-example"
    labels = {
      test = "FastApiExample"
    }
    namespace = "novi-k8s"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "FastApiExample"
      }
    }


    template {
      metadata {
        labels = {
          test = "FastApiExample"
        }
      }

      spec {
        container {
          image = "credmp/fastapi-example"
          name  = "fastapi"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8000
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
    metadata {
        name = "fastapi"
        namespace = "novi-k8s"
    }
    spec {
    selector = {
        test = "FastApiExample"
    }
    port {
      port = 8000
      target_port = 8000 # towards the container
    }
    type = "LoadBalancer"
  }
}
