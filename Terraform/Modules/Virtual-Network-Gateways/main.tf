terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rgname
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 3, 255)]  # e.g., 11.0.255.0/27 from 11.0.0.0/16
}

resource "azurerm_public_ip" "gateway_pip" {
  name                = "${var.env}-${var.location}-vng-pip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

# Virtual Network Gateway (VPN + BGP)
resource "azurerm_virtual_network_gateway" "vng" {
  name                = "${var.env}-${var.location}-vng"
  location            = var.location
  resource_group_name = var.rgname
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = true
  sku                 = "VpnGw1"  # Basic for dev

  ip_configuration {
    name                          = "${var.env}-${var.location}-vng-config"
    public_ip_address_id          = azurerm_public_ip.gateway_pip.id
    subnet_id                     = azurerm_subnet.gateway_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  bgp_settings {
    asn = var.asn  # e.g., 65001 for Spoke1
  }
}