resource_group_name = "MDC-Demo"

container_registry = {
    name                = "mdcdemoacr01"
    sku                 = "Basic"
    admin_enabled       = true
}

import_resources = {
    user_assigned_identity_name    = "mdc-demo-uai-01"
    user_assigned_identity_rg_name = "MDC-Demo"
}