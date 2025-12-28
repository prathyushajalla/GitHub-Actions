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
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 11, 2047)]  # e.g., 11.0.255.0/27 from 11.0.0.0/16
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.env}-${var.location}-nsg"
  location            = var.location
  resource_group_name = var.rgname

  # Allow BGP (TCP 179) from Hub/Route Server (inbound to VNG)
  security_rule {
    name                       = "${var.env}-${var.location}-allow-bgp-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "179"  # BGP port
    source_address_prefix      = var.hub_cidr #tighten to RS IP
    destination_address_prefix = "*"  # VNG itself
  }

  # Allow ICMP for testing (inbound from internal/VNet)
  security_rule {
    name                       = "${var.env}-${var.location}-allow-icmp-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"  # Or "*" for cross-spoke
    destination_address_prefix = "*"
  }

  # Allow SSH (22) from bastion/management IPs (inbound)
  security_rule {
    name                       = "${var.env}-${var.location}-allow-ssh-inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "AzureBastion"  #or your IP
    destination_address_prefix = "*"
  }

  # Catch-all Deny Inbound (evaluates last)
  security_rule {
    name                       = "${var.env}-${var.location}-deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Optional: Restrict Outbound (allow to Azure services, deny internet)
  security_rule {
    name                       = "${var.env}-${var.location}-allow-azure-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"  # Service tag for Azure endpoints
  }

  security_rule {
    name                       = "${var.env}-${var.location}-deny-internet-outbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  tags = {
    environment = "Development"
  }
}

resource "azurerm_subnet_network_security_group_association" "gateway_nsg_assoc" {
  subnet_id                 = azurerm_subnet.gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "gateway_pip" {
  name                = "${var.env}-${var.location}-vng-pip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Dynamic"
  sku                 = "Standard"

  tags = {
    environment = "Development"
  }
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
  tags = {
    environment = "Development"
  }

  depends_on = [azurerm_subnet.gateway_subnet]
}