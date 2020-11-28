resource "kubernetes_config_map" "rabbitmq" {
  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = var.configmap_annotations
    labels      = merge(local.common_labels, var.extra_labels)
  }
  data = {
    "rabbitmq.conf"   = <<EOF
cluster_formation.peer_discovery_backend = k8s
cluster_formation.k8s.host = kubernetes.default.svc.cluster.local
cluster_formation.k8s.address_type = hostname
cluster_formation.k8s.service_name = ${kubernetes_service.rabbitmq.metadata.0.name}
    EOF
    "enabled_plugins" = "[${join(",", local.enabled_plugins)}]."
  }
}
