provider "null" {
  version = "2.1.2"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID && az aks get-credentials --name ${local.env[var.environment].kubernetes_cluster_name} --resource-group ${local.env[var.environment].aks_resource_group_name} --admin"
    interpreter = ["/bin/sh", "-c"]
  }
  triggers = {
    build_number = timestamp()
  }
}

provider "azurerm" {
  subscription_id = local.env[var.environment].subscription_id
  version         = "2.28.0"
  features {}
}

provider "azuredevops" {
  version = "0.0.1"
  org_service_url       = var.org_service_url
  personal_access_token = var.azuredevops_personal_access_token
}

data "azurerm_kubernetes_cluster" "main" {
  name                = local.env[var.environment].kubernetes_cluster_name
  resource_group_name = local.env[var.environment].aks_resource_group_name
}

data "azurerm_subscription" "main" {
  subscription_id = local.env[var.environment].subscription_id
}

data "azuredevops_project" "main" {
  project_name = local.env[var.environment].azuredevops_project_name
}

provider "kubernetes" {
  version                = "1.13.2"
  config_context = "${local.env[var.environment].kubernetes_cluster_name}-admin"
}

resource "kubernetes_namespace" "main" {
  for_each = toset(local.env[var.environment].kubernetes_namespace_name)
  metadata {
    name   = each.key
  }
  depends_on = [
    null_resource.main
  ]
}

resource "azuredevops_serviceendpoint_kubernetes" "main" {
  for_each              = toset(local.env[var.environment].kubernetes_namespace_name)
  project_id            = data.azuredevops_project.main.id
  service_endpoint_name = "${local.env[var.environment].kubernetes_cluster_name} - ${each.key}"
  apiserver_url         = data.azurerm_kubernetes_cluster.main.kube_config.0.host
  authorization_type    = "AzureSubscription"
  azure_subscription {
    subscription_id   = local.env[var.environment].subscription_id
    subscription_name = data.azurerm_subscription.main.display_name
    tenant_id         = data.azurerm_subscription.main.tenant_id
    resourcegroup_id  = local.env[var.environment].aks_resource_group_name
    namespace         = each.key
    cluster_name      = local.env[var.environment].kubernetes_cluster_name
  }
  depends_on = [
    kubernetes_namespace.main
  ]
}