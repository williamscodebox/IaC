@echo off
setlocal

echo.
echo  Stopping Acquisition Development Environment
echo =================================================
echo.

:: ---------------------------------------------------------
:: Ensure we run from project root
:: ---------------------------------------------------------
cd /d "%~dp0\.."

:: ---------------------------------------------------------
:: Check if Docker is running
:: ---------------------------------------------------------
docker info >nul 2>&1
if errorlevel 1 (
    echo  Docker is not running. Nothing to stop.
    exit /b 0
)

:: ---------------------------------------------------------
:: Stop containers
:: ---------------------------------------------------------
echo  Stopping containers...
docker compose -f docker-compose.dev.yml down --remove-orphans

if errorlevel 1 (
    echo  Error: Failed to stop containers.
    exit /b 1
)

echo.
echo  ✓ Development environment stopped successfully.
echo.

endlocal
