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

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-${var.location}-RG"
  location = var.location

  tags = {
    environment = "Development"
  }
}

# 2. Virtual Network & Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env}-${var.location}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet for Web App (Requires Delegation)
resource "azurerm_subnet" "app_subnet" {
  name                 = "App-Integration-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/26"]

  delegation {
    name = "appservice-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for SQL Private Endpoint
resource "azurerm_subnet" "db_subnet" {
  name                 = "Private-Link-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/27"]
}

# 3. SQL Server (Disabled Public Access)
resource "azurerm_mssql_server" "sql" {
  name                         = "sql-server-ent-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "ComplexPassword123!"
  public_network_access_enabled = false # THIS SECURES IT
}

# 4. Private Endpoint for SQL
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "sql-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.db_subnet.id

  private_service_connection {
    name                           = "sql-privatelink"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

# 5. App Service Plan & Web App
resource "azurerm_service_plan" "plan" {
  name                = "app-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" # Lowest tier supporting VNet Integration
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-ent-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    vnet_route_all_enabled = true # Force all traffic through VNet
  }
}

# Connect Web App to Subnet
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = azurerm_subnet.app_subnet.id
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}