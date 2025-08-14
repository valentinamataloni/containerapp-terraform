terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "4dc63939-80f6-4f50-bd19-bc605cf2786d"
}

# Sufijo para evitar nombres duplicados
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# 1 - Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-containerapp-${random_integer.suffix.result}"
  location = "eastus2"
}

# 2 - Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "log-${random_integer.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 3 - Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                       = "env-containerapp-${random_integer.suffix.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

# 4 - Container App
resource "azurerm_container_app" "app" {
  name                         = "my-container-app-${random_integer.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name = "valentina-mysql"
      image  = "docker.io/valenmataloni/valentina-mysql:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true
    target_port = 3306
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

output "container_app_url" {
  value = azurerm_container_app.app.ingress[0].fqdn
}
