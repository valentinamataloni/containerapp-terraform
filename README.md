# Container App con Terraform y Despliegue en Jenkins

Este repositorio contiene una configuración básica para desplegar una aplicación en Azure Container Apps utilizando Terraform. Es ideal para automatizar la infraestructura como código (IaC) y gestionar contenedores en la nube de forma eficiente.

# 🚀 Descripción

Este proyecto permite crear y gestionar una aplicación en Azure Container Apps mediante Terraform. Incluye:

Definición de recursos de Azure Container Apps.

Configuración de variables y estado de Terraform.

Archivos de configuración para despliegue automatizado.

# 🛠️ Requisitos

Terraform instalado en tu máquina.

Cuenta de Azure con permisos para crear recursos.

Azure CLI configurada y autenticada.

# 📂 Estructura del repositorio
.

├── .gitignore

├── Jenkinsfile

├── main.tf

├── terraform.tfstate

├── terraform.tfstate.backup

└── variables.tf


.gitignore: Archivos y directorios que deben ser ignorados por Git.

Jenkinsfile: Pipeline de Jenkins para automatizar el despliegue.

main.tf: Definición principal de los recursos de Terraform.

terraform.tfstate: Estado actual de la infraestructura gestionada por Terraform.

terraform.tfstate.backup: Copia de seguridad del estado de Terraform.

variables.tf: Definición de variables utilizadas en la configuración de Terraform.

# ⚙️ Uso

Clona el repositorio:
git clone https://github.com/valentinamataloni/containerapp-terraform.git
cd containerapp-terraform

Inicializa Terraform:
terraform init

Aplica la configuración:
terraform apply

# 📦 Despliegue de la Aplicación con Jenkins

El pipeline de Jenkins automatiza:

Login en Azure y ACR.

Build de la imagen Docker y push a ACR.

Aplicación de Terraform para desplegar la imagen en Azure Container Apps.

Salida del URL de la aplicación desplegada.

Pasos:

Crea un nuevo pipeline en Jenkins y apunta al repositorio:

Tipo: Pipeline from SCM

Repositorio: https://github.com/valentinamataloni/containerapp-terraform.git

Script Path: Jenkinsfile

Configura las credenciales en Jenkins:

Azure Service Principal:
- ID de suscripción
- Client ID
- Client Secret
- Tenant ID

# Ejecuta el pipeline. 
Las etapas incluyen:
- Terraform Init & Apply
- Azure Login & ACR Login
- Build y push de la imagen Docker
- Deploy Container App
- Mostrar URL de la aplicación

- Accede a la aplicación desplegada mediante la URL que genera Terraform: my-container-app-XXXX.greendune-XXXX.eastus2.azurecontainerapps.io

<img width="1310" height="280" alt="Jenkins pipeline" src="https://github.com/user-attachments/assets/4e28fc6a-11ee-47db-9168-2c72a12e89bb" />
