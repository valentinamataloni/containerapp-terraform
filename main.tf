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
  subscription_id = var.subscription_id
}

# Sufijo para evitar nombres duplicados
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# 1 - Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
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

# 4 - Datos del ACR existente
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

# 5 - User Assigned Identity
resource "azurerm_user_assigned_identity" "identity" {
  name                = "identity-acr-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

# 6 - Container App con User Assigned Identity
resource "azurerm_container_app" "app" {
  name                         = "my-container-app-${random_integer.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  registry {
  server   = var.acr_server
  identity = azurerm_user_assigned_identity.identity.id
}


  template {
    container {
      name   = "nginx-app"
      image  = "${var.acr_server}/nginx-app:latest"
      cpu    = 0.5
      memory = "1Gi"
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# 7 - Permiso de AcrPull para la identidad
resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

# 8 - Output
output "container_app_url" {
  value = azurerm_container_app.app.ingress[0].fqdn
}
