pipeline {
  agent any

  environment {
    // Variables para Terraform (desde Jenkins Credentials)
    TF_VAR_subscription_id = credentials('azure-subscription-id')
    TF_VAR_client_id       = credentials('azure-client-id')
    TF_VAR_client_secret   = credentials('azure-client-secret')
    TF_VAR_tenant_id       = credentials('azure-tenant-id')

    // Variables de ACR y Docker
    ACR_NAME        = 'acrvmataloni'
    IMAGE_NAME      = 'nginx-app'
    IMAGE_TAG       = 'latest'
    RESOURCE_GROUP  = 'rg-vmataloni'
  }

  stages {
    stage('Debug Jenkins Secrets') {
      steps {
        echo "TF_VAR_client_secret length: ${TF_VAR_client_secret.length()} chars"
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        powershell '''
          terraform init
          terraform apply -auto-approve
        '''
      }
    }

    stage('Azure Login & ACR Login') {
      steps {
        powershell '''
          az login --service-principal -u $env:TF_VAR_client_id -p $env:TF_VAR_client_secret --tenant $env:TF_VAR_tenant_id
          az acr login --name $env:ACR_NAME
        '''
      }
    }

    stage('Verificar archivos Docker') {
      steps {
        powershell '''
          Write-Host "📂 Listando archivos del workspace..."
          Get-ChildItem -Recurse

          Write-Host "🔍 Buscando Dockerfile..."
          if (Test-Path "docker/Dockerfile") {
            Write-Host "✅ Dockerfile encontrado en docker/Dockerfile"
          } else {
            Write-Error "❌ No se encontró docker/Dockerfile. Revisa la estructura del repo."
            exit 1
          }
        '''
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        powershell '''
          $ACR_LOGIN_SERVER = az acr show --name $env:ACR_NAME --query loginServer -o tsv
          az acr login --name $env:ACR_NAME
          docker build -t "$ACR_LOGIN_SERVER/$env:IMAGE_NAME:$env:IMAGE_TAG" -f docker/Dockerfile docker
          docker push "$ACR_LOGIN_SERVER/$env:IMAGE_NAME:$env:IMAGE_TAG"
        '''
      }
    }

    stage('Output Container App URL') {
      steps {
        powershell 'terraform output container_app_url'
      }
    }
  }
}
