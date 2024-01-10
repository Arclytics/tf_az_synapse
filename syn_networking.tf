

# resource "azurerm_synapse_firewall_rule" "this" {
#   name                 = "AllowAll"
#   synapse_workspace_id = azurerm_synapse_workspace.this.id
#   start_ip_address     = "0.0.0.0"
#   end_ip_address       = "255.255.255.255"
# }

# resource "azurerm_synapse_managed_private_endpoint" "this" {
#   name                 = "mpe-keyvault"
#   synapse_workspace_id = azurerm_synapse_workspace.this.id
#   target_resource_id   = azurerm_key_vault.this.id


#   depends_on = [azurerm_synapse_firewall_rule.this]
# }
