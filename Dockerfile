# Этап 1: Сборка и публикация приложения
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS builder
WORKDIR /src

# Копируем файлы проектов для восстановления зависимостей (оптимизация кэширования слоев)
COPY Directory.Packages.props ./
COPY src/TodoApp.Domain/*.csproj src/TodoApp.Domain/
COPY src/TodoApp.Application/*.csproj src/TodoApp.Application/
COPY src/TodoApp.Infrastructure/*.csproj src/TodoApp.Infrastructure/
COPY src/TodoApp.Web/*.csproj src/TodoApp.Web/

# Восстановление зависимостей
RUN dotnet restore src/TodoApp.Web/TodoApp.Web.csproj

# Копируем весь исходный код
COPY src/ ./src/

# Публикация приложения
RUN dotnet publish src/TodoApp.Web/TodoApp.Web.csproj -c Release -o /app/publish --no-restore

# Установка dotnet-ef и создание бандла миграций
RUN dotnet tool install --global dotnet-ef
ENV PATH="$PATH:/root/.dotnet/tools"
RUN dotnet ef migrations bundle --self-contained -r linux-x64 \
    --project src/TodoApp.Infrastructure \
    --startup-project src/TodoApp.Web \
    --output /app/EfCoreMigrationsBundle

# Этап 2: Финальный образ для запуска
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

# Устанавливаем dos2unix для обработки скриптов (важно для Windows-пользователей)
RUN apt-get update && apt-get install -y dos2unix && rm -rf /var/lib/apt/lists/*

# Копируем опубликованное приложение
COPY --from=builder /app/publish .
# Копируем бандл миграций
COPY --from=builder /app/EfCoreMigrationsBundle .
# Копируем скрипт запуска
COPY scripts/apply-migrations.sh .

# Обработка окончаний строк и права на выполнение
RUN dos2unix apply-migrations.sh && chmod +x apply-migrations.sh EfCoreMigrationsBundle

# Пробрасываем порт (по умолчанию для ASP.NET Core)
EXPOSE 8080

# Используем скрипт в качестве точки входа
ENTRYPOINT ["/bin/sh", "./apply-migrations.sh"]
