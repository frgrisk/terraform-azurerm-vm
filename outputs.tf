output "private_ip_address" {
  value = azurerm_linux_virtual_machine.instance.private_ip_address
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.instance.public_ip_address
}

output "hostname" {
  value = var.hostname
}

output "instance_id" {
  value = azurerm_linux_virtual_machine.instance.id
}

output "identity" {
  value = azurerm_linux_virtual_machine.instance.identity
}
