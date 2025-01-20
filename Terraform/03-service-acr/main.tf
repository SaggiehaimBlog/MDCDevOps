provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>3.0"
  features {}
  
  skip_provider_registration = true
}

terraform {
  backend "azurerm" {
  }
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
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.container_registry.sku
  admin_enabled       = var.container_registry.admin_enabled
  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.app_uai.id
    ]
  }
}