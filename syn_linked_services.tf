



resource "azurerm_synapse_linked_service" "this" {
  name                 = "ls-keyvault"
  description          = "Key Vault linked service managed by Terraform"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  type                 = "AzureKeyVault"
  type_properties_json = <<JSON
{
  "baseUrl": "${azurerm_key_vault.this.vault_uri}"
}
JSON
}


