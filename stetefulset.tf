resource "kubernetes_stateful_set" "rabbitmq" {

  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = merge(local.common_labels, var.extra_labels)
  }

  spec {
    pod_management_policy = var.pod_management_policy
    replicas              = var.replicas

    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "rabbitmq"
        "app.kubernetes.io/instance" = var.instance
      }
    }

    service_name = kubernetes_service.rabbitmq.metadata.0.name

    template {

      metadata {
        labels = merge(local.common_labels, var.extra_labels)
      }

      spec {
        service_account_name            = kubernetes_service_account.rabbitmq.metadata.0.name
        automount_service_account_token = true

        security_context {
          run_as_user  = var.user_id
          run_as_group = var.group_id
          fs_group     = var.group_id
        }

        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secrets
          content {
            name = image_pull_secrets.value
          }
        }

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app.kubernetes.io/name"
                  operator = "In"
                  values   = [local.common_labels["app.kubernetes.io/name"]]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        init_container {
          name  = "rabbitmq-init"
          image = "busybox"
          command = [
            "chown",
            "-R",
            "${var.user_id}:${var.group_id}",
            "/var/lib/rabbitmq"
          ]
          
          security_context {
            run_as_user = 0
          }

          volume_mount {
            name       = "rabbitmq-mnesia"
            mount_path = "/var/lib/rabbitmq"
          }
        }

        container {
          name              = "rabbitmq"
          image             = "${var.image_name}:${var.image_tag}"
          image_pull_policy = var.image_pull_policy

          security_context {
            run_as_user  = var.user_id
            run_as_group = var.group_id
          }

          dynamic "port" {
            for_each = local.enabled_ports

            content {
              name           = port.value["name"]
              protocol       = port.value["protocol"]
              container_port = port.value["port"]
            }

          }

          env {
            name = "RABBITMQ_ERLANG_COOKIE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.rabbitmq.metadata.0.name
                key  = "erlang_cookie"
              }
            }
          }

          env {
            name = "RABBITMQ_DEFAULT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.rabbitmq.metadata.0.name
                key  = "default_user"
              }
            }
          }

          env {
            name = "RABBITMQ_DEFAULT_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.rabbitmq.metadata.0.name
                key  = "default_pass"
              }
            }
          }

          volume_mount {
            name       = "rabbitmq-mnesia"
            mount_path = "/var/lib/rabbitmq/mnesia"
          }

          volume_mount {
            name       = "rabbitmq-config"
            mount_path = "/etc/rabbitmq"
            read_only  = true
          }

          liveness_probe {
            period_seconds        = 30
            initial_delay_seconds = 5
            exec {
              command = [
                "rabbitmq-diagnostics", "-q", "ping"
              ]
            }
          }
        }

        dns_config { // https://github.com/kubernetes/kubernetes/issues/42544
          searches = ["${kubernetes_service.rabbitmq.metadata.0.name}.${var.namespace}.svc.${var.cluster_domain}"]
        }

        volume {
          name = "rabbitmq-config"
          config_map {
            name = kubernetes_config_map.rabbitmq.metadata.0.name
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = "rabbitmq-mnesia"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "2Gi"
          }

        }

      }

    }

  }

}
