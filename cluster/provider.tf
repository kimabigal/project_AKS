terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true
  subscription_id = var.subscription_id #new, ae 2nov,  11:56
}