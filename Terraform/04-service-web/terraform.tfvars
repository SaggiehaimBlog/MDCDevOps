resource_group_name = "MDC-Demo-rg"

app_service_plan = {
  name     = "mdc-demo-asp-01"
  kind     = "Linux"
  reserved = true
}

app_service_plan_sku = {
  tier = "Basic"
  size = "B1"
}

app_service = {
  name = "mdc-demo-web-01"
}

app_service_settings = {
  websites_port = "8080"
}

import_resources = {
  user_assigned_identity_name    = "mdc-demo-uai-01"
  user_assigned_identity_rg_name = "MDC-Demo-rg"
  container_registry_name        = "mdcdemoacr01"
  container_registry_rg_name     = "MDC-Demo-rg"
}