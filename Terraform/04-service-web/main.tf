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

data "azurerm_container_registry" "acr" {
  name                = var.import_resources.container_registry_name
  resource_group_name = var.import_resources.container_registry_rg_name
}

resource "azurerm_app_service_plan" "website" {
  name                = var.app_service_plan.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = var.app_service_plan.kind
  reserved            = var.app_service_plan.reserved

  sku {
    tier = var.app_service_plan_sku.tier
    size = var.app_service_plan_sku.size
  }
  tags = {
    git_commit           = "058590605289d3a654e50070414a0016d7790968"
    git_file             = "Terraform/04-service-web/main.tf"
    git_last_modified_at = "2025-01-21 00:24:16"
    git_last_modified_by = "contact@saggiehaim.net"
    git_modifiers        = "contact"
    git_org              = "SaggiehaimBlog"
    git_repo             = "MDCDevOps"
    yor_name             = "website"
    yor_trace            = "322c2c34-142b-4237-b4fb-19a0d773e689"
  }
}


resource "azurerm_app_service" "container" {
  name                = var.app_service.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.website.id
  https_only          = true

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.app_uai.id
    ]
  }

  site_config {
    linux_fx_version                    = "DOCKER|${data.azurerm_container_registry.acr.login_server}/newssite:latest"
    http2_enabled                       = true
    acr_user_managed_identity_client_id = data.azurerm_user_assigned_identity.app_uai.id
  }

  app_settings = {
    WEBSITES_PORT = var.app_service_settings.websites_port
  }
  tags = {
    git_commit           = "9adc17b50f30ba50027b1f3e7d958c5e4142598e"
    git_file             = "Terraform/04-service-web/main.tf"
    git_last_modified_at = "2025-01-21 00:49:11"
    git_last_modified_by = "contact@saggiehaim.net"
    git_modifiers        = "contact"
    git_org              = "SaggiehaimBlog"
    git_repo             = "MDCDevOps"
    yor_name             = "container"
    yor_trace            = "853fb338-bb87-42e8-a7d9-bf677b945297"
  }
}