output "vng_private_ip" {
  value = azurerm_virtual_network_gateway.vng.ip_configuration[0].private_ip_address_allocation
}

output "gateway_cidr" {
  description = "CIDR of the GatewaySubnet"
  value       = azurerm_subnet.gateway_subnet.address_prefixes[0]
}