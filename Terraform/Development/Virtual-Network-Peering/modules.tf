module "vir_net" {
  source                    = "../../Modules/Virtual-Network-Peering/"
  location                  = var.location
  env                       = var.env
  remote_virtual_network_id = data.azurerm_virtual_network.vnet.id
  virtual_network_name      = data.azurerm_virtual_network.vnet.name
}