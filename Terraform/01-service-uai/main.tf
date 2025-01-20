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

resource "azurerm_user_assigned_identity" "uai" {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.rg.location
  name                = var.user_assigned_identity_name
  tags                = data.azurerm_resource_group.rg.tags
}