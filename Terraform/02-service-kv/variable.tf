variable "resource_group_name" {
  description = "(Required) The name of the resource group to add the resource."
}

variable "keyvault_config" {
  description = "(Required) The config of the keyvault."
}

variable "kv_import_resources" {
  description = "(Required) the resources needed for import."
}
