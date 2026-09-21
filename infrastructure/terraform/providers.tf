terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
  }
  backend "azurerm" {
    use_azuread_auth = true
    resource_group_name  = "rg-cloudresumechallenge"
    storage_account_name = "tfstate19524"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}  
  storage_use_azuread = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "time" {}