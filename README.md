# TodoApp Backend

A minimal production-ready todo application backend demonstrating Clean Architecture, CQRS, and DevOps practices.

## Technology Stack

- .NET 10
- ASP.NET Core Web API
- Entity Framework Core (PostgreSQL)
- MediatR (CQRS)
- FluentValidation
- AutoMapper
- Serilog
- xUnit & WebApplicationFactory

## Getting Started

1. **Clone the repository**
2. **Navigate to the root directory**: `cd TodoApp.Backend`
3. **Database Setup**:
   - The application expects a PostgreSQL database.
   - Update connection string in `src/TodoApp.Web/appsettings.json` or use environment variables.
4. **Run Migrations**:

   ```bash
   dotnet ef database update --project src/TodoApp.Infrastructure --startup-project src/TodoApp.Web
   ```

5. **Run the Application**:

   ```bash
   dotnet run --project src/TodoApp.Web
   ```

## Docker Deployment

To run the entire stack (API + PostgreSQL) using Docker:

```bash
cd docker
docker-compose up --build
```

The API will be available at `http://localhost:5000`. Swagger documentation is available at `http://localhost:5000/swagger`.

## Migrations and Bundle

Create a new migration:

```bash
./scripts/create-migration.sh "MigrationName"
```

Create an executable migration bundle for Linux:

```bash
dotnet ef migrations bundle --self-contained -r linux-x64 --project src/TodoApp.Infrastructure --startup-project src/TodoApp.Web --output scripts/EfCoreMigrationsBundle
```

## Testing

Run integration tests:

```bash
dotnet test
```

## API Endpoints

- POST `/api/v1/auth/register`
- POST `/api/v1/auth/login`
- GET `/api/v1/todos`
- POST `/api/v1/todos`
- PUT `/api/v1/todos/{id}`
- DELETE `/api/v1/todos/{id}`
