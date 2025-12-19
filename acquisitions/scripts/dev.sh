#!/bin/bash

# Development startup script for Acquisition App with Neon Local
# This script starts the application in development mode with Neon Local

echo "🚀 Starting Acquisition App in Development Mode"
echo "================================================"

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "❌ Error: .env.development file not found!"
    echo "   Please copy .env.development from the template and update with your Neon credentials."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker Desktop and try again."
    exit 1
fi

# Create .neon_local directory if it doesn't exist
mkdir -p .neon_local

# Add .neon_local to .gitignore if not already present
if ! grep -q ".neon_local/" .gitignore 2>/dev/null; then
    echo ".neon_local/" >> .gitignore
    echo "✅ Added .neon_local/ to .gitignore"
fi

echo "📦 Building and starting development containers..."
echo "   - Neon Local proxy will create an ephemeral database branch"
echo "   - Application will run with hot reload enabled"
echo ""

# Run migrations with Drizzle
echo "📜 Applying latest schema with Drizzle..."
if ! npm run db:migrate; then
    echo "❌ Migration failed!"
    exit 1
fi

# Wait for the database to be ready
echo "⏳ Waiting for the database to be ready..."
until docker compose exec neon-local psql -U neon -d neondb -c 'SELECT 1' >/dev/null 2>&1; do
    sleep 2
done
echo "✅ Database is ready!"

# Optional: verify schema tables exist
echo "📋 Listing tables in neondb..."
docker compose exec neon-local psql -U neon -d neondb -c '\dt'

# Optional: check migration history
echo "📜 Migration history:"
docker compose exec neon-local psql -U neon -d neondb -c 'SELECT * FROM _drizzle_migrations;'


# Handle Ctrl+C gracefully
trap 'echo "🛑 Stopping containers..."; docker compose -f docker-compose.dev.yml down; exit 0' INT

# Reset log file and start development environment silently
: > .neon_local/dev.log
docker compose -f docker-compose.dev.yml up --build | tee .neon_local/dev.log > /dev/null


echo ""
echo "🎉 Development environment started!"
echo "   Application: http://localhost:5173"
echo "   Database: postgres://neon:npg@localhost:5432/neondb"
echo ""
echo "To stop the environment, press Ctrl+C or run: ./stop-dev.sh"
