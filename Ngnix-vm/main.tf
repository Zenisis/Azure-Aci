# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
data "azurerm_resource_group" "Redmine-Sandbox" {
  name     = "Redmine-Sandbox"
  #location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "redmine-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.Redmine-Sandbox.location
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name
}

resource "azurerm_subnet" "subnet" {
  name                  = "redmine-subnet"
  resource_group_name   = data.azurerm_resource_group.Redmine-Sandbox.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "redmine-public-ip"
  location            = data.azurerm_resource_group.Redmine-Sandbox.location
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name
  allocation_method   = "Dynamic"
}




# Create Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = data.azurerm_resource_group.Redmine-Sandbox.location
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name

  # Allow HTTP (80)
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS (443)
  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Port 3000
  security_rule {
    name                       = "Port_3000"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "redmine-nic"
  location            = data.azurerm_resource_group.Redmine-Sandbox.location
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name

  ip_configuration {
    name                          = "internal"
    subnet_id                    = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.public_ip.id
  }
}


Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = data.azurerm_network_interface.nic.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "redmine-vm"
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name
  location            = data.azurerm_resource_group.Redmine-Sandbox.location
  size               = "Standard_DS1_v2"  # Choose your VM size
  admin_username      = "yourusername"
  admin_password      = "yourpassword" # Use secure methods for passwords
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_ssh_key {
    username   = "yourusername"            # Must match your admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    #create_option       = "FromImage"
    storage_account_type   = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS"
    version   = "latest"
  }

  #custom_data = <<-EOF
              #!/bin/bash
             # sudo apt-get update
             # sudo apt-get install nginx -y 
              
              
              
             
             
             
            # EOF
}



output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true  # Mark the output as sensitive to prevent it from being displayed in plain text
}
