pipeline {
  agent any

  environment {
    # Variables para Terraform (desde Jenkins Credentials)
    TF_VAR_subscription_id = credentials('azure-subscription-id')
    TF_VAR_client_id       = credentials('azure-client-id')
    TF_VAR_client_secret   = credentials('azure-client-secret')
    TF_VAR_tenant_id       = credentials('azure-tenant-id')

    # Variables de ACR y Docker
    ACR_NAME        = 'acrvmataloni'
    IMAGE_NAME      = 'nginx-app'
    IMAGE_TAG       = 'latest'
    RESOURCE_GROUP  = 'rg-vmataloni'
  }

  stages {
    stage('Debug Jenkins Secrets') {
      steps {
        echo "TF_VAR_subscription_id length: ${TF_VAR_subscription_id.length()} chars"
        echo "TF_VAR_client_id length: ${TF_VAR_client_id.length()} chars"
        echo "TF_VAR_client_secret length: ${TF_VAR_client_secret.length()} chars"
        echo "TF_VAR_tenant_id length: ${TF_VAR_tenant_id.length()} chars"
      }
    }

    stage('Terraform Init & Infra Apply') {
      steps {
        dir('terraform/infra') {
          sh 'rm -rf .terraform terraform.tfstate terraform.tfstate.backup'
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Azure Login & ACR Login') {
      steps {
        sh '''
        set -euxo pipefail
        az login --service-principal -u $TF_VAR_client_id -p $TF_VAR_client_secret --tenant $TF_VAR_tenant_id
        az account show
        az acr login --name $ACR_NAME
        '''
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        dir('docker') {
          sh '''
          set -euxo pipefail
          ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
          docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
          docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy Container App') {
      steps {
        dir('terraform/app') {
          sh 'rm -rf .terraform terraform.tfstate terraform.tfstate.backup'
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Output Container App URL') {
      steps {
        dir('terraform/app') {
          script {
            def url = sh(script: "terraform output -raw container_app_url", returnStdout: true).trim()
            echo "🌐 La aplicación está disponible en: ${url}"
          }
        }
      }
    }
  }
}
