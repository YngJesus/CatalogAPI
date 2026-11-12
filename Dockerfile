# 1. Base Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
USER app

# 2. Build Stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project file and restore dependencies (cached layer)
COPY ["src/ProductCatalog.Api/ProductCatalog.Api.csproj", "ProductCatalog.Api/"]
RUN dotnet restore "ProductCatalog.Api/ProductCatalog.Api.csproj"

# Copy source code and build
COPY src/ProductCatalog.Api/ ProductCatalog.Api/
WORKDIR "/src/ProductCatalog.Api"
RUN dotnet build "ProductCatalog.Api.csproj" -c Release -o /app/build

# 3. Publish Stage
FROM build AS publish
RUN dotnet publish "ProductCatalog.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# 4. Final Minimal Image Stage
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProductCatalog.Api.dll"]