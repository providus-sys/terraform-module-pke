terraform {
  required_providers {
    # https://github.com/rancher/terraform-provider-rke/releases
    rke = {
      source  = "rancher/rke"
      version = "1.5.0"
    }
    # https://github.com/hashicorp/terraform-provider-kubernetes/releases
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  host                   = format("https://%s.%s:6443", local.pke_node_api[0], var.domain_name)
  username               = rke_cluster.pke.kube_admin_user
  client_certificate     = rke_cluster.pke.client_cert
  client_key             = rke_cluster.pke.client_key
  cluster_ca_certificate = rke_cluster.pke.ca_crt
}

locals {
  pke_name        = basename(abspath(path.cwd))
  pke_node_api    = var.nodes_api
  pke_node_worker = var.nodes_worker
  worker_tags = {
    do_ingress = "please"
    client     = "infra"
  }
}

resource "rke_cluster" "pke" {
  ssh_agent_auth        = var.use_ssh_agent
  cluster_name          = local.pke_name
  kubernetes_version    = var.pke_k8s_version
  ignore_docker_version = true
  enable_cri_dockerd    = true
  update_only           = true
  dynamic "nodes" {
    for_each = local.pke_node_api
    content {
      address           = "${nodes.value}.${var.domain_name}"
      hostname_override = nodes.value
      user              = "root"
      role              = ["controlplane", "etcd"]
    }
  }
  dynamic "nodes" {
    for_each = local.pke_node_worker
    content {
      address           = "${nodes.value}.${var.domain_name}"
      hostname_override = nodes.value
      user              = "root"
      role              = ["worker"]
      labels            = merge(local.worker_tags, var.worker_tags)
    }
  }
  upgrade_strategy {
    drain                        = true
    max_unavailable_controlplane = 1
    max_unavailable_worker       = 1
    drain_input {
      ignore_daemon_sets = true
      delete_local_data  = true
    }
  }
  ingress {
    provider        = var.ingress_default == true ? "nginx" : "none"
    http_port       = 80
    https_port      = 443
    network_mode    = "hostNetwork"
    default_backend = true
    options = {
      proxy-read-timeout        = "3600"
      proxy-body-size           = "50m"
      use-forwarded-headers     = true
      use-gzip                  = var.use_compression == true ? true : false
      enable-brotli             = var.use_compression == true ? true : false
      allow-snippet-annotations = true
      worker-processes          = var.ingress_ncpu == "auto" ? "auto" : var.ingress_ncpu
    }
    node_selector = {
      do_ingress = "please"
    }
  }

  authentication {
    sans = compact(concat(
      local.pke_node_api,
      [format("pke-%s.%s", local.pke_name, var.domain_name),
      can(var.custom_api_url) ? var.custom_api_url : null]
    ))
  }
}

resource "kubernetes_namespace" "namespaces" {
  depends_on = [rke_cluster.pke]
  for_each   = var.namespaces
  metadata {
    name = each.key
  }
  # Ignore changes to metadata caused externally after initial creation of the resource
  lifecycle {
    ignore_changes = [metadata[0].annotations, metadata[0].labels]
  }
}
resource "kubernetes_secret" "image_puller" {
  depends_on = [kubernetes_namespace.namespaces]
  for_each   = var.namespaces
  metadata {
    name      = var.image_puller
    namespace = each.key
  }
  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.registry_url) = {
          auth = base64encode("${var.registry_user}:${var.registry_pass}")
        }
      }
    })
  }
}
