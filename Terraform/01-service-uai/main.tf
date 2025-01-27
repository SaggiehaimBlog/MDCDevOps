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

resource "azurerm_user_assigned_identity" "uai" {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.rg.location
  name                = var.user_assigned_identity_name
  tags = merge(data.azurerm_resource_group.rg.tags, {
    git_commit           = "96d06b8815ed63028b6ee4a9cb7f012da9693662"
    git_file             = "Terraform/01-service-uai/main.tf"
    git_last_modified_at = "2025-01-20 19:38:42"
    git_last_modified_by = "contact@saggiehaim.net"
    git_modifiers        = "contact"
    git_org              = "SaggiehaimBlog"
    git_repo             = "MDCDevOps"
    yor_name             = "uai"
    yor_trace            = "4f8208b4-7b9a-4f28-bf19-2d12b905a328"
  })
}