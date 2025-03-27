resource_group_name                     = "MDC-Demo"

keyvault_config = {
    name                            = "MDC-Demo-kv"
    enabled_for_disk_encryption     = true
    soft_delete_retention_days      = 7
    purge_protection_enabled        = true
    enabled_for_template_deployment = true
    sku_name                        = "standard"
}

kv_import_resources = {
    user_assigned_identity_name     = "mdc-demo-uai-01"
    user_assigned_identity_rg_name = "MDC-Demo"
}