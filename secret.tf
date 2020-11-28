resource "kubernetes_secret" "rabbitmq" {
  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = var.secret_annotations
    labels      = merge(local.common_labels, var.extra_labels)
  }
  data = {
    erlang_cookie = random_password.erland_cookie.result
    default_user  = "admin"
    default_pass  = random_password.default_pass.result
  }
}

resource "random_password" "erland_cookie" {
  length  = 64
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "random_password" "default_pass" {
  length  = 24
  upper   = true
  lower   = true
  number  = true
  special = false
}
