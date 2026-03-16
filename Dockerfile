# Etapa de compilación
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar csproj y restaurar dependencias
COPY ["FrontEndBlazor.csproj", "./"]
RUN dotnet restore "FrontEndBlazor.csproj"

# Copiar todo el código fuente y compilar
COPY . .
RUN dotnet build "FrontEndBlazor.csproj" -c Release -o /app/build

# Publicar la aplicación
FROM build AS publish
RUN dotnet publish "FrontEndBlazor.csproj" -c Release -o /app/publish

# Etapa final: Servir con Nginx
FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html

# Copiar la salida publicada de Blazor WebAssembly al contenedor
COPY --from=publish /app/publish/wwwroot .

# Copiar la configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Exponer el puerto
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
