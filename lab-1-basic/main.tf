terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.5"
}

provider "azurerm" {
  features {}
}


data "azurerm_resource_group" "av-lab-rg" {
  name = "HT-IENO-LAB-006-elaraby-jalaleddine"
}

resource "azurerm_storage_account" "lab" {
  name                     = "tflabstr"
  resource_group_name      = data.azurerm_resource_group.av-lab-rg.name
  location                 = data.azurerm_resource_group.av-lab-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
