variable "instance" {
  description = "Instance name to add for multiple deployments"
  type        = string
  default     = "default"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "replicas" {
  description = "Number of cluster nodes. Recommended value is the one which equals number of kubernetes nodes"
  type        = number
  default     = 3
}

variable "user_id" {
  description = "Unix UID to apply to persistent volume"
  type        = number
  default     = 999
}

variable "group_id" {
  description = "Unix GID to apply to persistent volume"
  type        = number
  default     = 999
}

variable "additional_plugins" {
  description = "List of plugins to enable on start up"
  type        = list(string)
  default     = []
}

variable "cluster_domain" {
  description = "Due to a bug, resolv.conf is currently missing a crucial record https://github.com/kubernetes/kubernetes/issues/42544"
  type        = string
  default     = "cluster.local"
}

variable "image_name" {
  description = "Container image name including registry address. For images from Docker Hub short names can be used"
  type        = string
  default     = "rabbitmq"
}

variable "image_tag" {
  description = "Container image tag (version)"
  type        = string
  default     = "3.8.9-alpine"
}

variable "image_pull_secrets" {
  description = "List of image pull secrets to use with private registries"
  type        = list(string)
  default     = []
}

variable "image_pull_policy" {
  description = "Image pull policy. One of Always, Never or IfNotPresent"
  type        = string
  default     = "IfNotPresent"
}

variable "pod_management_policy" {
  description = "OrderedReady or Parallel"
  type        = string
  default     = "OrderedReady"
}

variable "statefulset_annotations" {
  description = "Annotations to apply to StatefulSet"
  type        = map(string)
  default     = null
}

variable "service_annotations" {
  description = "Annotation to apply to Service"
  type        = map(string)
  default     = null
}

variable "configmap_annotations" {
  description = "Annotation to apply to ConfigMap"
  type        = map(string)
  default     = null
}

variable "secret_annotations" {
  description = "Annotation to apply to Secret"
  type        = map(string)
  default     = null
}

variable "ingress_annotations" {
  description = "Annotations to apply to Ingress"
  type        = map(string)
  default     = null
}

variable "ingress_hosts" {
  description = "Controls whether or not ingress resource must be created"
  type = list(object(
    {
      host = string
      path = string
    }
  ))
  default = []
}

variable "extra_labels" {
  description = "Any extra labels to apply to all resources"
  type        = map(string)
  default     = {}
}
