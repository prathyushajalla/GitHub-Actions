terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate1766591150"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
    use_oidc             = true # Required since we're using OIDC in GitHub Actions
  }
}

provider "azurerm" {
  # Configuration options
  # Terraform requires this block to handle specific behaviors for Azure resources (like resource deletion policies).
  # Without it, the provider cannot initialize properly during the planning phase
  features {}
}

resource "azurerm_resource_group" "Test-RG" {
  name     = "Test-Resource-Group"
  location = "East US"
}

resource "azurerm_network_security_group" "NSG" {
  name                = "Network-Security-Group"
  location            = azurerm_resource_group.Test-RG.location
  resource_group_name = azurerm_resource_group.Test-RG.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  location            = azurerm_resource_group.Test-RG.location
  resource_group_name = azurerm_resource_group.Test-RG.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "subnet2"
    address_prefixes = ["10.0.2.0/24"]
    security_group   = azurerm_network_security_group.NSG.id
  }

  subnet {
    name             = "subnet3"
    address_prefixes = ["10.0.3.0/24"]
    security_group   = azurerm_network_security_group.NSG.id
  }
  tags = {
    environment = "Development"
  }
}