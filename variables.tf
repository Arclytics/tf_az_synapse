variable "resource_group_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "workspace_name" {
  type = string
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "git_settings" {
  type = object({
    provider        = string
    account_name    = string
    project_name    = optional(string)
    root_folder     = string
    repository_name = string
    branch_name     = string
  })
  default = null
}

variable "storage_settings" {
  type = object({
    name                     = string
    account_tier             = string
    account_replication_type = string
  })
}

variable "spark_pool_settings" {
  type = list(object({
    name             = string
    spark_version    = string
    node_size        = string
    node_count       = number
    node_size_family = string
  }))
}
variable "key_vault_settings" {
  type = object({
    name                     = string
    sku_name                 = string
    soft_delete_enabled      = bool
    purge_protection_enabled = bool
  })
}

variable "permission_settings" {
  type = list(object({
    role_definition_name = string
    user_names           = list(string)
  }))
  default = null
}

# variable "network_settings" {
#   type = object({
#     virtual_network_name = string
#     vnet_resource_group  = string
#     subnet_name          = string
#   })
#   default = null
# }


# data "virtual_network" "this" {
#   count               = var.network_settings.name != null ? 1 : 0
#   name                = var.network_settings.name
#   resource_group_name = var.resource_group_name
# }
