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
  use_oidc = true
  skip_provider_registration = true
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