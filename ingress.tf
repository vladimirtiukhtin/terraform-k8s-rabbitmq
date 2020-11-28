resource "kubernetes_ingress" "rabbitmq_management" {
  for_each = {
    for item in kubernetes_service.rabbitmq.spec.0.port : item["name"] => item if item["name"] == "management" && length(var.ingress_hosts) != 0
  }

  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = var.ingress_annotations
    labels      = merge(local.common_labels, var.extra_labels)
  }

  spec {
    dynamic "rule" {
      for_each = {
        for ingress in var.ingress_hosts : ingress["host"] => ingress
      }
      content {
        host = rule.value["host"]

        http {
          path {
            path = rule.value["path"]

            backend {
              service_name = kubernetes_service.rabbitmq.metadata.0.name
              service_port = each.key
            }
          }
        }
      }
    }
  }
}
