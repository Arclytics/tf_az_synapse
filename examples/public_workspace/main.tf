


module "synapse" {
  source                        = "../.."
  resource_group_name           = "tf-arc-syn-demo"
  location                      = "eastus"
  workspace_name                = "syn-arc-demo"
  stage                         = "dev"
  public_network_access_enabled = true
  git_settings = {
    # provider        = "AzureDevOps"
    # account_name    = "arclytics"
    # project_name    = "proj-sandbox"
    # root_folder     = "/synapse"
    # repository_name = "synapse-deployment-demo"
    # branch_name     = "main"
    provider        = "Github"
    account_name    = "bmeyn"
    root_folder     = "/synapse"
    repository_name = "synapse-cicd-templates"
    branch_name     = "main"
  }
  storage_settings = {
    name                     = "stsynarcdemo001"
    account_tier             = "Standard"
    account_replication_type = "LRS"

  }
  key_vault_settings = {
    name                     = "kvsynarcdemo"
    sku_name                 = "standard"
    soft_delete_enabled      = false
    purge_protection_enabled = false
  }

  spark_pool_settings = [{
    name             = "pool1"
    spark_version    = "2.4"
    node_size        = "Small"
    node_count       = 3
    node_size_family = "MemoryOptimized"
    },
    {
      name             = "pool2"
      spark_version    = "2.4"
      node_size        = "Small"
      node_count       = 3
      node_size_family = "MemoryOptimized"
  }]
  permission_settings = [{
    role_definition_name = "Storage Blob Data Reader"
    user_names           = ["bjarne@arclytics.de", "naby@arclytics.de"]
  }]
}

