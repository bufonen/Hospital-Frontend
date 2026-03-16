# Etapa de compilación
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copiar csproj y restaurar dependencias
COPY ["FrontEndBlazor.csproj", "./"]
RUN dotnet restore "FrontEndBlazor.csproj"

# Copiar todo el código fuente y compilar
COPY . .
RUN dotnet build "FrontEndBlazor.csproj" -c Release -o /app/build

# Publicar la aplicación
FROM build AS publish
RUN dotnet publish "FrontEndBlazor.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Etapa final: Ejecución con el Runtime de ASP.NET
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Configurar que escuche en el puerto que asigne Render
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Iniciar la aplicación
ENTRYPOINT ["dotnet", "FrontEndBlazor.dll"]
