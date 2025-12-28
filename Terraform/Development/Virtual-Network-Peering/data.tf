data "azurerm_resource_group" "rg" {
  name     = "${var.env}-${var.location}-RG"
}

data "azurerm_virtual_network" "vnet" {
  resource_group_name = "${var.env}-${var.location}-RG"
  name                = "${var.env}-${var.location}-vnet"
}