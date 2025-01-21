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
  use_msi = true
  skip_provider_registration = true
}
#######-----------Declaring Data for the process -----------------------------------------#

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name              =  var.resource_group_name
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
}