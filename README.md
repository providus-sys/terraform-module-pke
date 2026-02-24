# terraform-module-pke

Terraform module for creating a PKE (Providus Kubernetes Engine) cluster using Rancher RKE and the Kubernetes provider.

## Requirements

- Terraform >= 1.4.0
- Providers:
  - rancher/rke (>= 1.7.0)
  - hashicorp/kubernetes

## Usage Example

```hcl
module "pke" {
  source = "../terraform-module-pke"

  namespaces        = ["default", "app"]
  pke_k8s_version   = "1.30"
  nodes_api         = ["pke-api.domain.tld", "pke-api2.domain.tld", "pke-api3.domain.tld"]
  nodes_worker      = ["pke-worker1.domain.tld", "pke-worker2.domain.tld", "pke-worker3.domain.tld"]
  domain_name       = "cloud.domain.tld"
  worker_tags       = { env = "prod" }
  ingress_default   = true
  use_compression   = false
  use_brotli        = false
  ingress_ncpu      = "auto"
  image_puller      = "imgcred"
  registry_url      = "https://index.docker.io/v1/"
  registry_user     = "_default"
  registry_pass     = "password"
  custom_api_url    = ""
  custom_api_url2   = ""
  use_ssh_agent     = true
  ingress_forwarded_for = "X-Forwarded-For"
  max_pods          = "110"
}
```

## Input Variables

| Name                  | Description                                               | Type         | Default                        |
|-----------------------|-----------------------------------------------------------|--------------|--------------------------------|
| namespaces            | List of namespaces to be created on PKE                   | set(string)  | ["unconfigured-variable"]      |
| pke_k8s_version       | Version key for Kubernetes (see `k8s_version` map)        | string       | "v1.23.16-rancher2-1"          |
| nodes_api             | List of control/API nodes                                 | list(string) | ["pke-api"]                   |
| nodes_worker          | List of worker nodes                                      | list(string) | ["pke-worker"]                 |
| domain_name           | Domain name suffix                                        | string       | "cloud.itplatforma.com"        |
| worker_tags           | Optional tags for worker nodes                            | map(any)     | { default = "default" }        |
| ingress_default       | Deploy default nginx ingress controller                   | bool         | true                           |
| use_compression       | Enable gzip compression on ingress                        | bool         | false                          |
| use_brotli            | Enable brotli compression on ingress                      | bool         | false                          |
| ingress_ncpu          | CPUs for nginx ingress controller                         | string       | "auto"                        |
| image_puller          | Name of image puller secret                               | string       | "imgcred"                     |
| registry_url          | Image registry hostname                                   | string       | "https://index.docker.io/v1/"  |
| registry_user         | Image registry username                                   | string       | "_default"                    |
| registry_pass         | Image registry password                                   | string       | "passsword-not-set"            |
| custom_api_url        | Custom API domain for load-balancing                      | string       | ""                             |
| custom_api_url2       | Additional API domain for load-balancing                  | string       | ""                             |
| use_ssh_agent         | Enable SSH agent usage                                    | bool         | true                           |
| k8s_version           | Map of supported Kubernetes versions                      | map(string)  | see above                      |
| ingress_forwarded_for | Header name for real IP                                   | string       | "X-Forwarded-For"              |
| max_pods              | Max pods per node                                         | string       | "110"                          |

## Outputs

| Name             | Description                                  |
|------------------|----------------------------------------------|
| kubeconfig       | Kubernetes config (sensitive)                |
| cluster_name     | Name of the cluster                          |
| api_server_url   | API server URL                               |
| ca_crt           | Cluster CA certificate (sensitive)           |
| client_key       | Client key (sensitive)                       |
| client_cert      | Client certificate (sensitive)               |
| admin_user       | Admin user (sensitive)                       |
| rke_cluster_yaml | RKE cluster YAML (sensitive)                 |

## How to Apply

1. Initialize Terraform:
   ```sh
   terraform init
   ```
2. Review the plan:
   ```sh
   terraform plan
   ```
3. Apply the configuration:
   ```sh
   terraform apply
   ```

## Getting kubeconfig

After applying, extract the kubeconfig for kubectl:

```sh
terraform output -raw kubeconfig > kubeconfig.yaml
export KUBECONFIG=kubeconfig.yaml
kubectl version
```

## Notes
- Ensure your SSH agent is running and has the necessary keys loaded if `use_ssh_agent` is true.
- Adjust variables as needed for your environment.
- Review the `k8s_version` map for available Kubernetes versions.
