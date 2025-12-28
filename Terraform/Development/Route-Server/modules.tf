module "route_server" {
  source               = "../../Modules/Route-Server/"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  rgname               = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  env                  = var.env
  vnet_address_space   = data.azurerm_virtual_network.vnet.address_space[0]
}