# these outputs can be used like this:
# $ terraform output -raw module.pke.kubeconfig > kubeconfig.yaml
# $ export KUBECONFIG=kubeconfig.yaml
# $ kubectl version
output "kubeconfig" {
  sensitive = true
  value     = rke_cluster.pke.kube_config_yaml
}

output "cluster_name" {
  value = rke_cluster.pke.cluster_name
}
output "api_server_url" {
  value = rke_cluster.pke.api_server_url
}
output "ca_crt" {
  value = rke_cluster.pke.ca_crt
  sensitive = true
}
output "client_key" {
  value = rke_cluster.pke.client_key
  sensitive = true
}
output "client_cert" {
  value = rke_cluster.pke.client_cert
  sensitive = true
}
output "admin_user" {
  value = rke_cluster.pke.kube_admin_user
  sensitive = true
}
