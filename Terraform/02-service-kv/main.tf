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
  name  = var.resource_group_name
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

  tags = data.azurerm_resource_group.rg.tags
}

#######-----------Declaring Access Policy for the keyvault -----------------------------------------#


resource "azurerm_key_vault_access_policy" "app_uai" {
  key_vault_id = azurerm_key_vault.keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_user_assigned_identity.app_uai.principal_id

  secret_permissions = [
    "Get","List","Set","Delete","Purge","Recover"
  ]
}

resource "azurerm_key_vault_access_policy" "IAC-SPN" {
  key_vault_id = azurerm_key_vault.keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get","List","Set","Delete","Purge","Recover"
  ]
}