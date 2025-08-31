# PowerShell script to download the latest Minecraft server jar with SHA1 verification
# download-server.ps1

Write-Host "Checking Minecraft server jar..."

try {
    # Get the version manifest
    $versionManifestUrl = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    Write-Host "Fetching latest Minecraft server version information..."
    $versionManifest = Invoke-RestMethod -Uri $versionManifestUrl -UseBasicParsing
    
    # Get latest release version
    $latestRelease = $versionManifest.latest.release
    Write-Host "Latest release version: $latestRelease"
    
    # Find the version details URL
    $versionInfo = $versionManifest.versions | Where-Object { $_.id -eq $latestRelease }
    if (-not $versionInfo) {
        throw "Could not find version info for $latestRelease"
    }
    
    Write-Host "Fetching version details from: $($versionInfo.url)"
    $versionDetails = Invoke-RestMethod -Uri $versionInfo.url -UseBasicParsing
    
    # Get server download info
    $serverUrl = $versionDetails.downloads.server.url
    $serverSha1 = $versionDetails.downloads.server.sha1
    
    if (-not $serverUrl) {
        throw "Could not find server download URL"
    }
    
    if (-not $serverSha1) {
        throw "Could not find server SHA1 hash"
    }
    
    Write-Host "Expected SHA1: $serverSha1"
    
    # Check if server.jar exists and is valid
    $downloadNeeded = $true
    
    if (Test-Path "server.jar" -PathType Leaf) {
        Write-Host "Found existing server.jar, checking SHA1..."
        
        # Calculate SHA1 of existing file
        $hash = Get-FileHash -Path "server.jar" -Algorithm SHA1
        $localSha1 = $hash.Hash.ToLower()
        
        if ($localSha1 -eq $serverSha1) {
            Write-Host "Local server.jar SHA1 matches latest release, no download needed"
            $downloadNeeded = $false
        }
        else {
            Write-Host "Local SHA1: $localSha1"
            Write-Host "SHA1 mismatch, will download new server.jar"
            # Remove the invalid file
            Remove-Item "server.jar" -Force
        }
    }
    elseif (Test-Path "server.jar") {
        Write-Host "Found server.jar but it's not a regular file (possibly directory), removing..."
        Remove-Item "server.jar" -Recurse -Force
    }
    else {
        Write-Host "No server.jar found, will download"
    }
    
    if ($downloadNeeded) {
        Write-Host "Downloading Minecraft server $latestRelease..."
        Write-Host "Download URL: $serverUrl"
        
        # Download the server jar
        Invoke-WebRequest -Uri $serverUrl -OutFile "server.jar" -UseBasicParsing
        
        # Verify the downloaded file
        $downloadedHash = Get-FileHash -Path "server.jar" -Algorithm SHA1
        $downloadedSha1 = $downloadedHash.Hash.ToLower()
        
        if ($downloadedSha1 -eq $serverSha1) {
            Write-Host "Successfully downloaded and verified Minecraft server $latestRelease"
        }
        else {
            Write-Warning "Downloaded SHA1 ($downloadedSha1) does not match expected ($serverSha1)"
            Write-Warning "Download may be corrupted, but proceeding anyway"
        }
    }
    
    Write-Host "Minecraft server jar ready."
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}
