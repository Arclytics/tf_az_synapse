# resource "azurerm_role_assignment" "this" {
#   #TODO: Each user needs this to ba able to access the storage account data
#   scope                = azurerm_storage_account.this.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = data.azurerm_client_config.current.object_id
# }


locals {
  # convert permission_settings to a list with all the users. The variables will have mmultiple keys like storage, keyvault, etc.
  # We need to get all the users from all the keys and then remove duplicates
  user_permissions = distinct(flatten([
    for permission in var.permission_settings : [
      for user in permission.user_names : {
        user_name : user,
        role_definition_name : permission.role_definition_name
      }
    ]
  ]))
}

#! When authenticated with a service principal, this data source requires one of the following application roles: User.ReadBasic.All, User.Read.All or Directory.Read.All
data "azuread_user" "dynamic" {
  for_each            = { for permission in local.user_permissions : permission.user_name => permission }
  user_principal_name = each.key
}

resource "azurerm_role_assignment" "dynamic" {
  #TODO: Each user needs this to ba able to query the data lake with the sql pool
  for_each             = { for permission in local.user_permissions : permission.user_name => permission }
  scope                = azurerm_storage_account.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = data.azuread_user.dynamic[each.key].id
}


#TODO: Add Synapse workspace permissions

# resource "azurerm_synapse_role_assignment" "example" {
#   synapse_workspace_id = azurerm_synapse_workspace.example.id
#   role_name            = "Synapse SQL Administrator"
#   principal_id         = data.azurerm_client_config.current.object_id

#   depends_on = [azurerm_synapse_firewall_rule.example]
# }
