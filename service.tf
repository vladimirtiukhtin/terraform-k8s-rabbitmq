resource "kubernetes_service" "rabbitmq" {

  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = merge(local.common_labels, var.extra_labels)
  }

  spec {
    type = "ClusterIP"

    dynamic "port" {
      for_each = local.enabled_ports

      content {
        name        = port.value["name"]
        protocol    = port.value["protocol"]
        port        = port.value["port"]
        target_port = port.value["name"]
      }

    }

    publish_not_ready_addresses = true // Makes SRV records published without making liveness/readiness probes
    selector = {
      "app.kubernetes.io/name"     = "rabbitmq"
      "app.kubernetes.io/instance" = var.instance
    }

  }

}
