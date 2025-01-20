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

data "azurerm_container_registry" "acr" {
  name                = var.import_resources.container_registry_name
  resource_group_name = var.import_resources.container_registry_rg_name
}

resource "azurerm_app_service_plan" "website" {
  name                = var.app_service_plan.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = var.app_service_plan.kind
  reserved            = var.app_service_plan.reserved

  sku {
    tier = var.app_service_plan_sku.tier
    size = var.app_service_plan_sku.size
  }
}


resource "azurerm_app_service" "container" {
  name                = var.app_service.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.website.id

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.app_uai.id
    ]
  }

  site_config {
    linux_fx_version = "DOCKER|${data.azurerm_container_registry.acr.login_server}/newssite:latest"
  }

  app_settings = {
    WEBSITES_PORT = var.app_service_settings.websites_port
  }
}