Terraform K8s RabbitMQ Module
=============================

Terraform module to create following K8S resources:
- StatefulSet
- Service
- Secret
- ConfigMap
- Ingress (optionally)

# Contents
- [Required Input Variables](#variables)
- [Usage](#usage)
- [Outputs](#outputs)
- [Licence](#licence)
- [Author Information](#author)

## <a name="variables"></a> Required Input Variables
Module does not require any input variables. See [full list](variables.tf) of supported variables

## <a name="usage"></a> Usage

To provision 3-nodes cluster in default namespace use:
```hcl-terraform
module "rabbitmq" {
  source = "./modules/k8s_rabbitmq"
}
```

Multiple deployments are also supported:

```hcl-terraform
module "rabbitmq_dev1" {
  source   = "./modules/k8s_rabbitmq"
  instance = "dev1"
}

module "rabbitmq_dev2" {
  source   = "./modules/k8s_rabbitmq"
  instance = "dev2"
}
```

To enable rabbitmq_management plugin and expose it via cluster ingress controller use:

```hcl-terraform
module "rabbitmq" {
  source = "./modules/k8s_rabbitmq"
  additional_plugins = [
    "rabbitmq_management"
  ]
  ingress_hosts = [
    {
      host = "rabbitmq.${local.domain_name}"
      path = "/"
    }
  ]
}
```

To specify necessary ingress annotations and/or any extra labels use:

```hcl-terraform
module "rabbitmq" {
  source = "./modules/k8s_rabbitmq"
  additional_plugins = [
    "rabbitmq_management"
  ]
  ingress_annotations = {
    "kubernetes.io/ingress.class"                        = "traefik"
    "traefik.ingress.kubernetes.io/redirect-entry-point" = "https"
    "traefik.ingress.kubernetes.io/redirect-permanent"   = "true"
  }
  ingress_hosts = [
    {
      host = "rabbitmq.${local.domain_name}"
      path = "/"
    }
  ]
  extra_labels = {
    "app.kubernetes.io/part-of"     = lower(var.project_name)
    "app.kubernetes.io/environment" = local.environment
  }
}
```

## <a name="outputs"></a> Outputs
Full list of module's outputs and descriptions can be found in [outputs.tf](outputs.tf)

## <a name="license"></a> License
The module is being distributed under [MIT Licence](LICENCE.txt). Please make sure you have read, understood and agreed
to its terms and conditions

## <a name="author"></a> Author Information
Vladimir Tiukhtin <vladimir.tiukhtin@hippolab.ru><br/>London
