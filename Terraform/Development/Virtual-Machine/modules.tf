module "virtual-machine" {
  source                    = "../../Modules/Virtual-Machine/"
  env                       = var.env
  location                  = data.azurerm_resource_group.rg.location
  rgname                    = data.azurerm_resource_group.rg.name
  virtual_network_name      = data.azurerm_virtual_network.vnet.name
  vnet_address_space        = data.azurerm_virtual_network.vnet.address_space[0]
  vm_count                  = 2
  network_security_group_id = data.azurerm_network_security_group.nsg.id
  admin_username            = var.admin_username
  admin_password            = var.admin_password
}