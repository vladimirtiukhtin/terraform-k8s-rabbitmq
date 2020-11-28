terraform {
  required_version = ">=0.12.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=1.13.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0.0"
    }
  }

}

locals {
  name            = var.instance == "default" ? "rabbitmq" : "rabbitmq-${var.instance}"
  enabled_plugins = distinct(compact(concat(["rabbitmq_peer_discovery_k8s"], var.additional_plugins)))
  enabled_ports = merge(
    {
      epmd = { name = "epmd", protocol = "TCP", port = 4369 }
      amqp = { name = "amqp", protocol = "TCP", port = 5672 }
    }, contains(local.enabled_plugins, "rabbitmq_management") ?
    { management = { name = "management", protocol = "TCP", port = 15672 } } : {}
  )
  common_labels = {
    "app.kubernetes.io/name"       = "rabbitmq"
    "app.kubernetes.io/instance"   = var.instance
    "app.kubernetes.io/version"    = var.image_tag
    "app.kubernetes.io/managed-by" = "terraform"
  }
}
