output "gateway_ip" {
  value = azurerm_virtual_network_gateway.vng.ip_configuration.private_ip_address_allocation[0]
}