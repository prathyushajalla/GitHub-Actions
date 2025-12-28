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

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.env}-${var.location}-nsg"
  location            = var.location
  resource_group_name = "${var.env}-${var.location}-RG_name"

  security_rule {
    name                       = "${var.env}-${var.location}-security-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Development"
  }
}



resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "${var.rgname}-${var.location}-hub-to-spoke" #HUB always has to be Central US for this architecture
  resource_group_name          = "${var.env}-${var.location}-RG_name"
  virtual_network_name         = var.hub_virtual_network_name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true  # Enables BGP propagation
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${var.rgname}-${var.location}-spoke-to-hub"
  resource_group_name          = var.rgname
  virtual_network_name         = var.spoke_virtual_network_name.name
  remote_virtual_network_id    = var.hub_virtual_network.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true  # Enables BGP propagation
  use_remote_gateways          = true
}