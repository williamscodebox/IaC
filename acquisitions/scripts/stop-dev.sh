#!/bin/bash

# Teardown script for Acquisition App with Neon Local
# Stops containers, removes ephemeral branches, and cleans local state

echo "🛑 Stopping Acquisition App Development Environment"
echo "==================================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker Desktop if you want to stop containers."
    exit 1
fi

# Stop and remove containers
echo "📦 Shutting down containers..."
docker compose -f docker-compose.dev.yml down

# Remove ephemeral Neon Local state
if [ -d ".neon_local" ]; then
    echo "🧹 Cleaning up .neon_local directory..."
    rm -rf .neon_local
fi

echo ""
echo "✅ Development environment stopped and cleaned!"
echo "   To restart, run: ./dev.sh"
