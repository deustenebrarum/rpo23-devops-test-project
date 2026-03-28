# Этап сборки (Builder)
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS builder
WORKDIR /source

# 1. Копируем файлы проектов для восстановления зависимостей
COPY Directory.Packages.props ./
COPY src/TodoApp.Domain/*.csproj src/TodoApp.Domain/
COPY src/TodoApp.Application/*.csproj src/TodoApp.Application/
COPY src/TodoApp.Infrastructure/*.csproj src/TodoApp.Infrastructure/
COPY src/TodoApp.Web/*.csproj src/TodoApp.Web/

# 2. Восстанавливаем пакеты (кэшируем этот слой)
RUN dotnet restore src/TodoApp.Web/TodoApp.Web.csproj

# 3. Копируем весь код и компилируем
COPY src/ ./src/
RUN dotnet publish src/TodoApp.Web/TodoApp.Web.csproj -c Release -o /app/publish --no-restore

# 4. Устанавливаем инструмент миграций и собираем бандл
RUN dotnet tool install --global dotnet-ef
ENV PATH="$PATH:/root/.dotnet/tools"
COPY ./scripts/make-migration-bundle.sh ./scripts/
RUN chmod +x ./scripts/make-migration-bundle.sh
RUN ./scripts/make-migration-bundle.sh

# Этап запуска (Runtime)
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

# Копируем всё необходимое из билдера
COPY --from=builder /app/publish .
COPY --from=builder /app/scripts/EfCoreMigrationsBundle .
COPY scripts/apply-migrations.sh .

# Исправляем права и окончания строк
RUN chmod +x apply-migrations.sh EfCoreMigrationsBundle

EXPOSE 8080

# Используем скрипт-обертку для наката миграций ПЕРЕД запуском приложения
ENTRYPOINT ["/bin/sh", "./apply-migrations.sh"]
