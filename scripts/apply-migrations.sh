#!/bin/sh
set -e

# Мы используем CONNECTION_STRING из переменных окружения (в Docker Compose это Host=db)
echo "--- Применение миграций базы данных ---"
./EfCoreMigrationsBundle --connection "$ConnectionStrings__DefaultConnection"

echo "--- Запуск приложения ---"
dotnet TodoApp.Web.dll
