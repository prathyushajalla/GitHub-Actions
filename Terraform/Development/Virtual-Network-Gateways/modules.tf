module "gateways" {
  source               = "../../Modules/Virtual-Network-Gateways/"
  virtual_network_name = data.azurerm_virtual_network.vnet
  rgname               = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  vnet_address_space   = data.azurerm_virtual_network.vnet.address_space
  env                  = var.env
  asn                  = var.asn
}