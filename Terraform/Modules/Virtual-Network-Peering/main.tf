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

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "dev-usc-RG-hub-to-${var.env}-${var.location}-RG-spoke" #HUB always has to be Central US for this architecture
  resource_group_name          = "dev-usc-RG"
  virtual_network_name         = "dev-usc-vnet"
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true  # Enables BGP propagation
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${var.env}-${var.location}-RG-spoke-to-dev-usc-RG-hub"
  resource_group_name          = "${var.env}-${var.location}-RG"
  virtual_network_name         = var.virtual_network_name.name
  remote_virtual_network_id    = "dev-usc-vnet".id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true  # Enables BGP propagation
  use_remote_gateways          = true
}