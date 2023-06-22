# Setup...
$shrName = "ima"
$evtName = "kcdc"
$appName = "kcdcWeb"
$apiName = "kcdcApi"
$acrName = "bnk23acr"
$aksName = "bnk23-aks"
$rg = "kcdc-demos-rg"
$env = "kcdc23"


# pull starter code into event folder

# Add API
dotnet new webapi -o .code\kcdcApi
dotnet sln add .code\kcdcApi


# Project Tye : https://github.com/dotnet/tye/blob/main/docs/README.md

dotnet tool update -g Microsoft.Tye --version "0.11.0-alpha.22111.1"

tye run
tye build
tye push -i
tye deploy -i

# Basic Dockerfile
cd .\code\$apiName
dotnet build --configuration release
dotnet publish -c release -o dist
cd .\dist
dotnet myApp.dll


# add docker file to ./myApp folder

cd .\code\kcdcWeb\ # so we're in .\myApp
$imgName = "$evtName"+"web:simple"
docker build -t kcdcweb:simple -f ./code/kcdcWeb/Dockerfile.simple ./code/kcdcWeb
docker image list kcdcweb:simple
docker run -p 5001:80 -d kcdcweb:simple
# http://localhost:5001
docker container list
docker container stop 6eee
docker container rm 6eee


# Dockerbuild
docker build -f ./code/kcdcWeb/Dockerfile -t kcdcweb:v1 ./code/kcdcWeb --build-arg tag=v1
docker build -f ./code/kcdcApi/Dockerfile -t kcdcapi:v1 ./code/kcdcApi --build-arg tag=v1
docker image list kcdcweb:v1
docker run -p 5002:80 -d  kcdcweb:v1
# http://localhost:5002 


# add docker-compose to ./ folder
docker-compose build
docker-compose up -d
docker-compose down 
# http://localhost:5100

# using bnk.azurecr.io
$acrName = "$acrName.azurecr.io"
az acr login -n $acrName

# Docker build on ACR & push image
az acr build --image bnk23acr.azurecr.io/kcdcweb:v2 --registry bnk23acr -f ./code/kcdcWeb/Dockerfile ./code/kcdcWeb --build-arg tag=v2
az acr build --image bnk23acr.azurecr.io/kcdcapi:v2 --registry bnk23acr -f ./code/kcdcApi/Dockerfile ./code/kcdcApi --build-arg tag=v2
az acr image list -o table

# Azure Container Apps
az containerapp up -n kcdcweb-aca -g $rg --environment $env --image bnk23acr.azurecr.io/kcdcweb:v2 --ingress external
az containerapp up -n kcdcapi-aca -g $rg --environment $env --image bnk23acr.azurecr.io/kcdcapi:v2
az containerapp list -o table
az containerapp update -n bnk-aca-myapp -g $rg --set-env-vars "EnvName=kcdc"


# Kubernetes
az aks get-credentials -n bnk-aks -g rg-shared-cus
kubectl cluster-info

# Run some pods
kubectl run myapp-pod --image  bnk23acr.azurecr.io/kcdcweb:v2 --env="EnvName=K8S"

kubectl exec -ti myapp-pod -- bash
kubectl port-forward myapp-pod 8080:80
kubectl get all
kubectl logs myapp-pod
kubectl delete pod myapp-pod

kubectl get all -A

# Deploy the VSL app
kubectl create namespace kcdc23
kubectl apply -n kcdc23 -f k8s-kcdc.yml 
kubectl apply -n kcdc23 -f k8s  # deploy folder

