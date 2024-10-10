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

data "azurerm_container_registry" "acr" {
  name                = "redmineacrxyz123"
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name
}

resource "azurerm_container_group" "redmine_container" {
  name                = "redmine-container"
  location            = data.azurerm_resource_group.Redmine-Sandbox.location
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name
  ip_address_type     = "Public"
  dns_name_label      = "redmine-demo"
  os_type             = "Linux"

  image_registry_credential {
    server   = data.azurerm_container_registry.acr.login_server
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
  }

  container {
    name   = "redmine"
    image  = "${data.azurerm_container_registry.acr.login_server}/redmine:latest"
    cpu    = "2.0"
    memory = "2.0"

    ports {
      port     = 3000
      protocol = "TCP"
    }
    environment_variables = {
      REDMINE_PORT = "3000"
    }
    
  }
  





    
}




# Output the FQDN of the container group
output "redmine_fqdn" {
  value = azurerm_container_group.redmine_container.fqdn
}
