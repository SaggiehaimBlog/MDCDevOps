variable "resource_group_name" {
  description = "(Required) The name of the resource group to add the resource."
}

variable "app_service_plan" { 
  description = "App Service Plan"
  type = object({
    name     = string
    kind     = string
    reserved = bool
  })
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU"
  type = object({
    tier = string
    size = string
  })
}

variable "app_service" {
  description = "App Service"
  type = object({
    name = string
  })
  
}

variable "app_service_settings" {
  description = "App Service Settings"
  type = object({
    websites_port = string
  })
  
}

variable "import_resources" {
  description = "Import resources"
  type = object({
    user_assigned_identity_name    = string
    user_assigned_identity_rg_name = string
    container_registry_name        = string
    container_registry_rg_name     = string
  })
  
}