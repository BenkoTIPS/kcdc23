
# Naming standards
$appName = "ima23"

# set this to the name of your Azure Container Registry.  It must be globally unique
$rgName = "rg-shared-cus"
$acrName="bnkacr23"
$aksName="bnk23-aks"
$acaEnvName="$appName-acaenv"
$acaName="$appName-aca-app"



# Run the following line to create an Azure Container Registry if you do not already have one
az acr create -n $acrName -g $rgName --sku Standard

# Create an AKS cluster with ACR integration
az aks create -n $aksName -g $rgName --generate-ssh-keys --attach-acr $acrName --node-vm-size "standard_d2as_v5"

# Connect
az acr login -n $acrName
az aks get-credentials --resource-group $rgName --name $aksName

# Azure Container Apps
az containerapp env create -n $acaEnvName --resource-group $rgName --location centralus
az containerapp create --name $acaName -g $rgName --environment $acaEnvName --image bnkacr.azurecr.io/vslapp:v1.0 --target-port 80 --ingress 'external' --query properties.configuration.ingress.fqdn

az containerapp list -o table
az containerapp update -n bnk-aca-myapp -g bnk-demos-rg --set-env-vars "EnvName=ACA-myApp"

