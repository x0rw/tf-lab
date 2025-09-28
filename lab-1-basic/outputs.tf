output "resource_group_name" {
  value = data.azurerm_resource_group.av-lab-rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.lab.name
}
