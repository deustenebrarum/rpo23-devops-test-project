dotnet ef migrations bundle --self-contained -r linux-x64 \
  --project src/TodoApp.Infrastructure \
  --startup-project src/TodoApp.Web \
  --output scripts/EfCoreMigrationsBundle
