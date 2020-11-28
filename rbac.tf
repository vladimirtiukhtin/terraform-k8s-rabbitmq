resource "kubernetes_service_account" "rabbitmq" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = merge(local.common_labels, var.extra_labels)
  }
}

resource "kubernetes_role" "rabbitmq" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = merge(local.common_labels, var.extra_labels)
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding" "rabbitmq" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = merge(local.common_labels, var.extra_labels)
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.rabbitmq.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rabbitmq.metadata.0.name
    namespace = var.namespace
  }
}
