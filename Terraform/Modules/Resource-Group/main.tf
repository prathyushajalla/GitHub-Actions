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
resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-${var.location}-RG"
  location = var.location

  tags = {
    environment = "Development"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env}-${var.location}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]

  tags = {
    environment = "Development"
  }
}