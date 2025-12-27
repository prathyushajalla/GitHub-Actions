terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {
    azurerm = azurerm
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsgname
  location            = var.location
  resource_group_name = var.rgname

  security_rule {
    name                       = var.security_rule_name
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

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rgname
  address_space       = var.vnet_address_space
#  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Development"
  }
}

resource "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address
}

resource "azurerm_subnet" "snet1" {
  name                 = var.subnet_name1
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address1
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_association1" {
  subnet_id                 = azurerm_subnet.snet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}