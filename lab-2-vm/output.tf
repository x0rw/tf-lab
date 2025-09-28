output "vm_name" {
  value = azurerm_linux_virtual_machine.lab_vm.name
}

output "resource_group" {
  value = data.azurerm_resource_group.lab.name
}

output "public_ip" {
  value = azurerm_public_ip.lab_pip.ip_address
}
