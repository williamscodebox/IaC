# Reset Acquisition App Development Environment (PowerShell)

Write-Host "🔄 Resetting Acquisition App Development Environment..."

# Stop containers and clean up
& .\stop-dev.ps1

# Start containers again, passing along any arguments
& .\dev.ps1 @args
