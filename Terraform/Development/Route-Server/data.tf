data "azurerm_resource_group" "RG" {
  name = var.rgname
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rgname
}