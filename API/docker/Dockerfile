# syntax=docker/dockerfile:1.7
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /source
# Sadece çözüm kökü kopyalanır; global.json, Directory.*.props ve .editorconfig
# ECommerceBackend/ içinde durduğu için build'in dışarıdan başka bir şeye ihtiyacı yok.
COPY ECommerceBackend/ ECommerceBackend/
# Host'tan sızan bin/obj kalıntıları temizlenir: obj/*.nuget.g.props Windows yolları
# içerir ve Linux SDK konteynerinde restore'u bozar.
RUN find ECommerceBackend -type d \( -name bin -o -name obj \) -prune -exec rm -rf {} +
# Test projeleri publish'e girmediği için sln yerine sadece API ve bağımlılıkları restore edilir.
RUN dotnet restore ECommerceBackend/ECommerce.Api/ECommerce.Api.csproj
RUN dotnet publish ECommerceBackend/ECommerce.Api/ECommerce.Api.csproj -c Release --no-restore -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080 \
    DOTNET_EnableDiagnostics=0
COPY --from=build --chown=$APP_UID:$APP_UID /app/publish .
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "ECommerce.Api.dll"]
