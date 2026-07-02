output "vm_id" {
  value = azurerm_linux_virtual_machine.week7.id
}

output "public_ip_address" {
  value = azurerm_public_ip.week7.ip_address
}
