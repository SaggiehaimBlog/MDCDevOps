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
  name                = var.kv_import_resources.user_assigned_identity_name
  resource_group_name = var.kv_import_resources.user_assigned_identity_rg_name
}


#######-----------Declaring the Key vaults for the process -----------------------------------------#

resource "azurerm_key_vault" "keyvault" {
  name                            = var.keyvault_config.name
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = var.keyvault_config.enabled_for_disk_encryption
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = var.keyvault_config.soft_delete_retention_days
  purge_protection_enabled        = var.keyvault_config.purge_protection_enabled
  enabled_for_template_deployment = var.keyvault_config.enabled_for_template_deployment
  sku_name                        = var.keyvault_config.sku_name

  tags = merge(data.azurerm_resource_group.rg.tags, {
    git_commit           = "96d06b8815ed63028b6ee4a9cb7f012da9693662"
    git_file             = "Terraform/02-service-kv/main.tf"
    git_last_modified_at = "2025-01-20 19:38:42"
    git_last_modified_by = "contact@saggiehaim.net"
    git_modifiers        = "contact"
    git_org              = "SaggiehaimBlog"
    git_repo             = "MDCDevOps"
    yor_name             = "keyvault"
    yor_trace            = "275a4784-dcde-4d5e-9b88-1b4e614e9069"
  })
}

#######-----------Declaring Access Policy for the keyvault -----------------------------------------#


resource "azurerm_key_vault_access_policy" "app_uai" {
  key_vault_id = azurerm_key_vault.keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_user_assigned_identity.app_uai.principal_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}

resource "azurerm_key_vault_access_policy" "IAC-SPN" {
  key_vault_id = azurerm_key_vault.keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}