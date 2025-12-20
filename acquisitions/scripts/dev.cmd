@echo off
setlocal enabledelayedexpansion

:: ---------------------------------------------------------
:: Always run from project root (script is inside /scripts)
:: ---------------------------------------------------------
cd /d "%~dp0\.."

echo.
echo  Starting Acquisition App in Development Mode
echo =================================================
echo.

:: ---------------------------------------------------------
:: Check for .env.development
:: ---------------------------------------------------------
if not exist .env.development (
    echo  Error: .env.development file not found!
    exit /b 1
)

:: ---------------------------------------------------------
:: Check if Docker is running
:: ---------------------------------------------------------
docker info >nul 2>&1
if errorlevel 1 (
    echo  Error: Docker is not running!
    exit /b 1
)

:: ---------------------------------------------------------
:: Ensure .neon_local exists
:: ---------------------------------------------------------
if not exist .neon_local mkdir .neon_local

:: ---------------------------------------------------------
:: Start Docker containers in background
:: ---------------------------------------------------------
echo  Starting Docker containers...
docker compose -f docker-compose.dev.yml up -d --build

if errorlevel 1 (
    echo  Error: Failed to start Docker containers!
    exit /b 1
)

echo.
echo  Containers started. Waiting for Neon Local to become healthy...
echo.

:: ---------------------------------------------------------
:: Wait for Neon Local health status
:: ---------------------------------------------------------
set MAX_RETRIES=60
set RETRY=0

:waitloop
for /f "delims=" %%H in ('docker inspect -f "{{.State.Health.Status}}" acquisitions-neon-local 2^>nul') do (
    set HEALTH=%%H
)

if "!HEALTH!"=="healthy" (
    echo  ✓ Neon Local is healthy!
    goto db_ready
)

set /a RETRY+=1
if !RETRY! GEQ %MAX_RETRIES% (
    echo  ❌ Timeout: Neon Local did not become healthy.
    exit /b 1
)

echo  Waiting for Neon Local... (!RETRY!/%MAX_RETRIES!)
timeout /t 2 >nul
goto waitloop

:db_ready

echo.
echo  Applying latest schema with Drizzle...
call npm run db:migrate

if errorlevel 1 (
    echo  Migration failed!
    exit /b 1
)

echo.
echo  Starting full development environment...
echo  (Logs will stream below)
echo.

docker compose -f docker-compose.dev.yml up --build

endlocal
