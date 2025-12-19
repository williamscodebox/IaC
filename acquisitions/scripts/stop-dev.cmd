@echo off


docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running!
    exit /b 1
)

echo 🛑 Stopping containers...
docker compose -f docker-compose.dev.yml down

if exist .neon_local (
    rmdir /s /q .neon_local
    echo ✅ Cleaned up .neon_local
)

echo 🎉 Environment stopped and cleaned up!
