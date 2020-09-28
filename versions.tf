terraform {
  required_providers {
    azuredevops = {
      source = "terraform-providers/azuredevops"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.13"
}
