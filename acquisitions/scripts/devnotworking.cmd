@echo off
setlocal

:: Always run from the directory where this script lives
cd /d "%~dp0\.."

echo  Starting Acquisition App in Development Mode
echo =================================================

:: Check if .env.development exists
if not exist .env.development (
    echo  Error: .env.development file not found!
    echo    Please copy .env.development from the template and update with your Neon credentials.
    exit /b 1
)

:: Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo  Error: Docker is not running!
    echo    Please start Docker Desktop and try again.
    exit /b 1
)

:: Create .neon_local directory if it doesn't exist
if not exist .neon_local (
    mkdir .neon_local
)

:: Add .neon_local to .gitignore if not already present
findstr /c:".neon_local/" .gitignore >nul 2>&1
if errorlevel 1 (
    echo .neon_local/ >> .gitignore
    echo  Added .neon_local/ to .gitignore
)

echo  Building and starting development containers...
echo    - Neon Local proxy will create an ephemeral database branch
echo    - Application will run with hot reload enabled
echo.

:: Wait for the database to be ready
echo ⏳ Waiting for the database to be ready...
:waitloop
docker compose -f docker-compose.dev.yml exec app ^
  sh -c "PGPASSWORD=%DB_PASSWORD% psql -h neon-local -U neondb_owner -d neondb -c 'SELECT 1'" >nul 2>&1

if errorlevel 1 (
    timeout /t 2 >nul
    goto waitloop
)
echo  Database is ready!


:: Run migrations with Drizzle
echo  Applying latest schema with Drizzle...
call npm run db:migrate
if errorlevel 1 (
    echo  Migration failed!
    exit /b 1
)

:: Optional: verify schema tables exist
echo  Listing tables in neondb...
docker compose -f docker-compose.dev.yml exec neon-local psql -U neon -d neondb -c "\dt"

:: Optional: check migration history
echo  Migration history:
docker compose -f docker-compose.dev.yml exec neon-local psql -U neon -d neondb -c "SELECT * FROM _drizzle_migrations;"

:: Reset log file and start development environment silently
type nul > .neon_local\dev.log

docker compose -f docker-compose.dev.yml up --build > .neon_local\dev.log 2>&1


echo.
echo  Development environment started!
echo    Application: http://localhost:5173
echo    Database: postgres://neon:npg@localhost:5432/neondb
echo.
echo To stop the environment, press Ctrl+C and then run: stop-dev.cmd

endlocal
