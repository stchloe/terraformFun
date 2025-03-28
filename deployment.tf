resource "kubernetes_namespace" "sample_namespace" {
  metadata {
    name = "sample"
  }
}

resource "kubernetes_deployment" "sample_deployment" {
  metadata {
    name      = "nginx-sample"
    namespace = kubernetes_namespace.sample_namespace.id
    labels = {
      test = "nginx-sample"
    }
    annotations = {
      deployed-by = "Terraform"
    }
  }

  spec {
    replicas = 0

    selector {
      match_labels = {
        test = "nginx-sample"
      }
    }

    template {
      metadata {
        labels = {
          test = "nginx-sample"
        }
      }

      spec {
        container {
          image = "nginx:1.19"
          name  = "nginx-app"

          resources {
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "sample_app_service" {
  metadata {
    name      = "nginx-sample-service"
    namespace = kubernetes_namespace.sample_namespace.id
  }

  spec {
    type = "ClusterIP"

    selector = {
      test = "nginx-sample"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}