resource "kubernetes_deployment" "aws-cli-deployment" {

  metadata {
    namespace = "default"
    name      = "aws-cli-deployment"
    labels = {
      app = "aws-cli"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "aws-cli"
      }
    }

    template {
      metadata {
        labels = {
          app = "aws-cli"
        }
      }

      spec {
        service_account_name = "aws-cli-sa"

        container {
          image = "amazon/aws-cli:latest"
          name  = "aws-cli"

          port {
            container_port = 5000
          }

          env {
            name  = "AWS_SECRET_NAME"
            value = "my-secret"
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

