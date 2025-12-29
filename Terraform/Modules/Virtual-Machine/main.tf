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

resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.env}-${var.location}-subnet"
  resource_group_name  = var.rgname
  virtual_network_name = var. virtual_network_name

# Uses net num '0' to start at the very beginning of the VNet space
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 8, 0)]
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.env}-${var.location}-vm-nic"
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Use the ID from the data lookup for your VM association
resource "azurerm_network_interface_security_group_association" "vm_nic_assoc" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh-22"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.existing_resource_group_name
  network_security_group_name = var.existing_security_group_name
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.env}-${var.location}-vm"
  resource_group_name             = var.rgname
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false # Password-based for quick testing

  network_interface_ids = [ azurerm_network_interface.vm_nic.id ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Cloud-init script for initial setup
  custom_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - iputils-ping
      - traceroute
    EOF
  )
}