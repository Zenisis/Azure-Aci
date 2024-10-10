resource "azurerm_container_registry" "acr" {
  name                = "redmineacrxyz123"  # Change this to a unique name
  resource_group_name = data.azurerm_resource_group.Redmine-Sandbox.name
  location            = data.azurerm_resource_group.Redmine-Sandbox.location
  sku                 = "Basic"
  admin_enabled       = true
}

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
