variable "namespaces" {
  description = "List of namespaces to be created on PKE"
  type        = set(string)
  default     = ["unconfigured-variable"]
}

variable "pke_k8s_version" {
  description = "Version of the Kubernetes"
  type        = string
  default     = "v1.23.16-rancher2-1"
}

variable "nodes_api" {
  description = "List of control/API nodes"
  type        = list(string)
  default     = ["pke-api"]
}
variable "nodes_worker" {
  description = "List of worker nodes"
  type        = list(string)
  default     = ["pke-worker"]
}
variable "domain_name" {
  description = "Domain name suffix"
  type        = string
  default     = "cloud.itplatforma.com"
}
variable "worker_tags" {
  description = "Optional tags to be added on worker nodes"
  type        = map(any)
  default     = { default = "default" }
}

variable "ingress_default" {
  description = "Set to true in case you want default nginx, or false if you plan to install custom one"
  type = bool
  default = true
}
