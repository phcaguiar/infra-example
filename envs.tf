locals {
  env = {      
    stg = {
      subscription_id                  = "efcaa4e1-17a2-4fa8-8723-927f72b11559"
      aks_resource_group_name          = "financialsystems-common-ec2-stg"
      kubernetes_cluster_name          = "aks-ctr-dmz-nonprod"
      kubernetes_namespace_name        = ["test-phcaguiar"]
      azuredevops_project_name         = "fin-controllership"
    }
  }
}