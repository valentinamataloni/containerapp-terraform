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
        sh 'terraform init'
        sh 'terraform apply -auto-approve'
      }
    }

    stage('Azure Login & ACR Login') {
      steps {
        sh '''
          az login --service-principal -u $TF_VAR_client_id -p $TF_VAR_client_secret --tenant $TF_VAR_tenant_id
          az acr login --name $ACR_NAME
        '''
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        sh '''
          ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
          docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
          docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
        '''
      }
    }

    stage('Output Container App URL') {
      steps {
        sh 'terraform output container_app_url'
      }
    }
  }
}

    
