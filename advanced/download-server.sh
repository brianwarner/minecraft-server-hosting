#!/bin/bash

echo "Checking Minecraft server jar..."

# Get the version manifest first
VERSION_MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
echo "Fetching latest Minecraft server version information..."
VERSION_MANIFEST=$(curl -s "$VERSION_MANIFEST_URL")

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch version manifest"
    exit 1
fi

# Extract latest release version info using jq
LATEST_RELEASE=$(echo "$VERSION_MANIFEST" | jq -r '.latest.release')
echo "Latest release version: $LATEST_RELEASE"

if [ "$LATEST_RELEASE" = "null" ] || [ -z "$LATEST_RELEASE" ]; then
    echo "Error: Could not extract latest release version"
    exit 1
fi

# Get the version-specific manifest URL using jq
VERSION_URL=$(echo "$VERSION_MANIFEST" | jq -r ".versions[] | select(.id == \"$LATEST_RELEASE\") | .url")

if [ -z "$VERSION_URL" ]; then
    echo "Error: Could not find version URL for $LATEST_RELEASE"
    exit 1
fi

echo "Fetching version details from: $VERSION_URL"
VERSION_DETAILS=$(curl -s "$VERSION_URL")

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch version details"
    exit 1
fi

# Extract server download info using jq
SERVER_URL=$(echo "$VERSION_DETAILS" | jq -r '.downloads.server.url')
SERVER_SHA1=$(echo "$VERSION_DETAILS" | jq -r '.downloads.server.sha1')

if [ "$SERVER_URL" = "null" ] || [ -z "$SERVER_URL" ]; then
    echo "Error: Could not find server download URL"
    exit 1
fi

if [ "$SERVER_SHA1" = "null" ] || [ -z "$SERVER_SHA1" ]; then
    echo "Error: Could not find server SHA1 hash"
    exit 1
fi

echo "Expected SHA1: $SERVER_SHA1"

# Check if server.jar exists and is valid
DOWNLOAD_NEEDED=true

if [ -f "server.jar" ]; then
    echo "Found existing server.jar, checking SHA1..."
    if command -v sha1sum >/dev/null 2>&1; then
        LOCAL_SHA1=$(sha1sum server.jar | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        LOCAL_SHA1=$(shasum -a 1 server.jar | cut -d' ' -f1)
    else
        echo "Warning: No SHA1 utility found, will re-download server.jar"
        LOCAL_SHA1=""
    fi
    
    if [ "$LOCAL_SHA1" = "$SERVER_SHA1" ]; then
        echo "Local server.jar SHA1 matches latest release, no download needed"
        DOWNLOAD_NEEDED=false
    else
        echo "Local SHA1: $LOCAL_SHA1"
        echo "SHA1 mismatch, will download new server.jar"
        # Remove the invalid file/directory
        rm -rf server.jar
    fi
elif [ -e "server.jar" ]; then
    echo "Found server.jar but it's not a regular file (possibly directory), removing..."
    rm -rf server.jar
else
    echo "No server.jar found, will download"
fi

if [ "$DOWNLOAD_NEEDED" = true ]; then
    echo "Downloading Minecraft server $LATEST_RELEASE..."
    echo "Download URL: $SERVER_URL"
    
    # Download with curl
    if curl -L -o server.jar "$SERVER_URL"; then
        echo "Download completed successfully"
        
        # Verify the downloaded file
        if command -v sha1sum >/dev/null 2>&1; then
            DOWNLOADED_SHA1=$(sha1sum server.jar | cut -d' ' -f1)
        elif command -v shasum >/dev/null 2>&1; then
            DOWNLOADED_SHA1=$(shasum -a 1 server.jar | cut -d' ' -f1)
        else
            echo "Warning: Cannot verify download SHA1"
            DOWNLOADED_SHA1=""
        fi
        
        if [ "$DOWNLOADED_SHA1" = "$SERVER_SHA1" ]; then
            echo "Successfully downloaded and verified Minecraft server $LATEST_RELEASE"
        elif [ -n "$DOWNLOADED_SHA1" ]; then
            echo "Warning: Downloaded SHA1 ($DOWNLOADED_SHA1) does not match expected ($SERVER_SHA1)"
            echo "Download may be corrupted, but proceeding anyway"
        fi
    else
        echo "Error: Failed to download server jar"
        exit 1
    fi
fi

echo "Minecraft server jar ready."
