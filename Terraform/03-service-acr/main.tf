terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  use_oidc                   = true
  skip_provider_registration = true
}
#######-----------Declaring Data for the process -----------------------------------------#

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "app_uai" {
  name                = var.import_resources.user_assigned_identity_name
  resource_group_name = var.import_resources.user_assigned_identity_rg_name
}

resource "azurerm_container_registry" "acr" {
  name                = var.container_registry.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.container_registry.sku
  admin_enabled       = var.container_registry.admin_enabled
  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.app_uai.id
    ]
  }
  tags = {
    git_commit           = "3bdd066f269c5e824092fef8cd30e27f857fe5a0"
    git_file             = "Terraform/03-service-acr/main.tf"
    git_last_modified_at = "2025-01-21 00:14:16"
    git_last_modified_by = "contact@saggiehaim.net"
    git_modifiers        = "contact"
    git_org              = "SaggiehaimBlog"
    git_repo             = "MDCDevOps"
    yor_name             = "acr"
    yor_trace            = "eda21465-b9f6-4d90-8930-355ceb008830"
  }
}