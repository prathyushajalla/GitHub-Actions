terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

#provider "azurerm" {
#  features {}
#}

resource "azurerm_subnet" "rs_subnet" {
  name                 = "RouteServerSubnet"
  virtual_network_name = var.vnetname.name
  resource_group_name  = var.rgname
  address_prefixes     = var.rs_prefixes
}

resource "azurerm_public_ip" "rs_pip" {
  name                = "${var.rgname}-${var.location}-rs-pip"
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_server" "hub_rs" {
  name                             = "${var.rgname}-${var.location}-hub-rs"
  resource_group_name              = var.rgname
  location                         = var.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.rs_pip.id
  subnet_id                        = azurerm_subnet.rs_subnet.id
  branch_to_branch_traffic_enabled = true
}

resource "azurerm_route_server_bgp_connection" "hub_to_spoke1" {
  name           = "hub-to-spoke1-bgp"
  route_server_id = azurerm_route_server.hub_rs.id

  peer_ip        = "10.1.1.1"  # Gateway IP in Spoke 1 subnet
  peer_asn       = 65001       # Spoke 1 ASN
}

resource "azurerm_route_server_bgp_connection" "hub_to_spoke2" {
  name           = "hub-to-spoke2-bgp"
  route_server_id = azurerm_route_server.hub_rs.id

  peer_ip        = "10.2.1.1"  # Spoke 2
  peer_asn       = 65002
}