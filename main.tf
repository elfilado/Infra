# Definition des ressources Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }
  }
  required_version = "1.3.8"
}

provider "azurerm" {
  features {}
  tenant_id       = "b7b023b8-7c32-4c02-92a6-c8cdaa1d189c"
  subscription_id = "dada0207-f9c8-4fae-9cf7-ea1567b2de11"
}

# Resource Group
resource "azurerm_resource_group" "gaming_1" {
  name     = var.rg_name
  location = var.rg_location
}

# Application Service Plan
resource "azurerm_service_plan" "gaming_1" {
  name                = var.asp_name
  location            = azurerm_resource_group.gaming_1.location
  resource_group_name = azurerm_resource_group.gaming_1.name
  os_type             = "Windows"
  sku_name            = var.asp_sku_name
}

# Web Application
resource "azurerm_windows_web_app" "gaming_1" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.gaming_1.name
  location            = azurerm_service_plan.gaming_1.location
  service_plan_id     = azurerm_service_plan.gaming_1.id

  site_config {
    application_stack {
      dotnet_version = var.dotnet_version
    }
  }
}

# SQL Server
resource "azurerm_mssql_server" "gaming_1" {
  name                         = var.db_server_name
  resource_group_name          = azurerm_resource_group.gaming_1.name
  location                     = azurerm_resource_group.gaming_1.location
  version                      = var.sql_version
  administrator_login          = var.db_login
  administrator_login_password = var.db_password

  tags = {
    environment = "production"
  }
}

# SQL Database
resource "azurerm_mssql_database" "gaming_1" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.gaming_1.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false
}

# The Azure feature Allow access to Azure services can be enabled by setting start_ip_address and end_ip_address to 0.0.0.0
resource "azurerm_sql_firewall_rule" "gaming_1" {
  name                = "FirewallRule1"
  resource_group_name = azurerm_resource_group.gaming_1.name
  server_name         = azurerm_sql_server.gaming_1.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}