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
:: Check for .env.production file
:: ---------------------------------------------------------
if not exist .env.production (
    echo  Error: .env.production file not found!
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


echo "📦 Building and starting production container..."
echo "   - Using Neon Cloud Database (no local proxy)"
echo "   - Running in optimized production mode"
echo ""



echo  Starting Docker containers...
docker compose -f docker-compose.prod.yml up -d --build

if errorlevel 1 (
    echo  Error: Failed to start Docker containers!
    exit /b 1
)

echo.
echo  Applying latest schema with Drizzle...
call npm run db:migrate

if errorlevel 1 (
    echo  Migration failed!
    exit /b 1
)

echo.
echo  Starting full production environment...
echo  (Logs will stream below)
echo.

docker compose -f docker-compose.prod.yml up

endlocal
