/**
 * # Azure Synapse Analytics Terraform module
  *
  * Terraform module which creates Synapse Analytics resources on Azure.
  *
 */

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_@%"
}

data "azurerm_client_config" "current" {}


resource "azurerm_synapse_workspace" "this" {

  name                                 = var.workspace_name
  resource_group_name                  = azurerm_resource_group.this.name
  location                             = azurerm_resource_group.this.location
  sql_administrator_login              = "SQLAdmin"
  sql_administrator_login_password     = random_password.password.result
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.this.id
  public_network_access_enabled        = var.public_network_access_enabled
  managed_virtual_network_enabled      = true
  identity {
    type = "SystemAssigned"
  }

  dynamic "azure_devops_repo" {
    for_each = var.git_settings.provider == "AzureDevOps" ? [var.git_settings] : []
    content {
      account_name    = azure_devops_repo.value["account_name"]
      project_name    = azure_devops_repo.value["project_name"]
      root_folder     = azure_devops_repo.value["root_folder"]
      repository_name = azure_devops_repo.value["repository_name"]
      branch_name     = azure_devops_repo.value["branch_name"]
    }
  }

  dynamic "github_repo" {
    for_each = var.git_settings.provider == "Github" ? [var.git_settings] : []
    content {
      account_name    = github_repo.value["account_name"]
      root_folder     = github_repo.value["root_folder"]
      repository_name = github_repo.value["repository_name"]
      branch_name     = github_repo.value["branch_name"]
    }
  }

  tags = {
    Environment = var.stage
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.this.id
}


resource "azurerm_synapse_spark_pool" "this" {
  for_each             = { for pool in var.spark_pool_settings : pool.name => pool }
  name                 = each.key
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  node_size_family     = each.value.node_size_family #"MemoryOptimized"
  spark_version        = each.value.spark_version    #"2.4"
  node_size            = each.value.node_size        #"Small"
  node_count           = each.value.node_count       #3
  max_executors        = 0
  min_executors        = 0
  tags = {
    Environment = var.stage
  }
}

resource "azurerm_key_vault" "this" {
  name                     = var.key_vault_settings.name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  sku_name                 = var.key_vault_settings.sku_name #"standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = var.key_vault_settings.purge_protection_enabled #false
  tags = {
    Environment = var.stage
  }
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = azurerm_key_vault.this.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  secret_permissions = [
    "Get", "Set", "List", "Delete", "Purge"
  ]
}


resource "azurerm_key_vault_secret" "sql_password" {
  depends_on   = [azurerm_key_vault_access_policy.this]
  name         = "sql-admin-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_storage_account" "this" {
  name                     = var.storage_settings.name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.storage_settings.account_tier             #"Standard"
  account_replication_type = var.storage_settings.account_replication_type #"LRS"
  tags = {
    Environment = var.stage
  }
}
