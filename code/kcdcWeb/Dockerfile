# Basic Dockerfile
# 
# docker build -f ./code/kcdcWeb/Dockerfile -t kcdcWeb:v0.1 ./code/kcdcWeb --build-arg tag=v0.1

FROM mcr.microsoft.com/dotnet/sdk:7.0 as build
WORKDIR /src
COPY kcdcWeb.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:7.0 as publish
WORKDIR /app
ENV EnvName=Docker
COPY --from=build /app .
ENTRYPOINT ["dotnet","kcdcWeb.dll"]