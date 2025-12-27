module "route_server" {
  source      = "../../Modules/Route-Server/"
  vnetname    = data.azurerm_virtual_network.vnet
  rgname      = data.azurerm_resource_group.RG.name
  location    = data.azurerm_resource_group.RG.location
  rs_prefixes = var.rs_prefixes

  #providers = {
  #  azurerm = azurerm # This passes the parent provider to the child
  #}
}

