# https://hub.docker.com/_/microsoft-dotnet-sdk/
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dev
ARG PFX_PASSWORD=development_certificate
WORKDIR /tmp/dev-certs
RUN dotnet dev-certs https --export-path /tmp/dev-certs/aspnetapp.pfx --password $PFX_PASSWORD

# https://hub.docker.com/_/microsoft-dotnet-aspnet/
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS image
ARG PFX_PASSWORD=development_certificate
ARG HTTPS_PORT=8443
WORKDIR /app
COPY build/app /app
COPY --from=dev /tmp/dev-certs/aspnetapp.pfx /app/aspnetapp.pfx
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/app/aspnetapp.pfx \
    ASPNETCORE_Kestrel__Certificates__Default__Password=${PFX_PASSWORD:-development_certificate} \
    ASPNETCORE_URLS="https://*:${HTTPS_PORT:-8443}"
EXPOSE ${HTTPS_PORT:-8443}
ENTRYPOINT ["dotnet", "ApiService.WebApi.dll"]
