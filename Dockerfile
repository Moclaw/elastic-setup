#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["host/Mlaw.UserServices.HttpApi.Host/Mlaw.UserServices.HttpApi.Host.csproj", "host/Mlaw.UserServices.HttpApi.Host/"]
COPY ["src/Mlaw.UserServices.HttpApi/Mlaw.UserServices.HttpApi.csproj", "src/Mlaw.UserServices.HttpApi/"]
COPY ["src/Mlaw.UserServices.Application.Contracts/Mlaw.UserServices.Application.Contracts.csproj", "src/Mlaw.UserServices.Application.Contracts/"]
COPY ["src/Mlaw.UserServices.Domain.Shared/Mlaw.UserServices.Domain.Shared.csproj", "src/Mlaw.UserServices.Domain.Shared/"]
COPY ["src/Mlaw.UserServices.Application/Mlaw.UserServices.Application.csproj", "src/Mlaw.UserServices.Application/"]
COPY ["src/Mlaw.UserServices.Domain/Mlaw.UserServices.Domain.csproj", "src/Mlaw.UserServices.Domain/"]
COPY ["src/Mlaw.UserServices.EntityFrameworkCore/Mlaw.UserServices.EntityFrameworkCore.csproj", "src/Mlaw.UserServices.EntityFrameworkCore/"]
RUN dotnet restore "./host/Mlaw.UserServices.HttpApi.Host/Mlaw.UserServices.HttpApi.Host.csproj"
COPY . .
WORKDIR "/src/host/Mlaw.UserServices.HttpApi.Host"
RUN dotnet build "./Mlaw.UserServices.HttpApi.Host.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Mlaw.UserServices.HttpApi.Host.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Mlaw.UserServices.HttpApi.Host.dll"]