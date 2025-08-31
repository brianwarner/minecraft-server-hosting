# Minecraft Docker Management Script for Windows
# PowerShell script to manage your Dockerized Minecraft server

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "logs", "restart", "start-multi", "update", "backup", "help")]
    [string]$Action
)

function Show-Help {
    Write-Host "Minecraft Docker Management Script"
    Write-Host "Usage: .\minecraft-docker.ps1 -Action <action>"
    Write-Host ""
    Write-Host "Available actions:"
    Write-Host "  start       - Start the Minecraft server"
    Write-Host "  stop        - Stop the Minecraft server"
    Write-Host "  logs        - View server logs (Ctrl+C to exit)"
    Write-Host "  restart     - Restart the server"
    Write-Host "  start-multi - Start multiple servers"
    Write-Host "  update      - Update server and restart"
    Write-Host "  backup      - Create a backup of server data"
    Write-Host "  help        - Show this help"
}

switch ($Action) {
    "start" {
        Write-Host "Starting Minecraft server..."
        docker-compose up -d
    }
    "stop" {
        Write-Host "Stopping Minecraft server..."
        docker-compose down
    }
    "logs" {
        Write-Host "Showing server logs (Ctrl+C to exit)..."
        docker-compose logs -f minecraft-server
    }
    "restart" {
        Write-Host "Restarting Minecraft server..."
        docker-compose restart minecraft-server
    }
    "start-multi" {
        Write-Host "Starting multiple servers..."
        docker-compose --profile multi-server up -d
    }
    "update" {
        Write-Host "Updating server and restarting..."
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
    }
    "backup" {
        $backupFile = "minecraft-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').tar.gz"
        Write-Host "Creating backup: $backupFile"
        docker run --rm -v minecraft-server-hosting_minecraft-data:/data -v ${PWD}:/backup alpine tar czf /backup/$backupFile -C /data .
        Write-Host "Backup created: $backupFile"
    }
    "help" {
        Show-Help
    }
}
