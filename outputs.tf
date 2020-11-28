output "service_name" {
  description = "Extracts service name from its metadata"
  value       = kubernetes_service.rabbitmq.metadata.0.name
}

output "service_port" {
  description = "Produces a map of port names and their values, e.g. {'epmd': 4369, 'ampq': 5672, 'management': 15672}"
  value = {
    for item in kubernetes_service.rabbitmq.spec.0.port : item["name"] => item["port"]
  }
}

output "erlang_cookie" {
  value = random_password.erland_cookie.result
}

output "default_user" {
  value = "admin"
}

output "default_pass" {
  value = random_password.default_pass.result
}
