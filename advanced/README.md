# Advanced Minecraft Server Setup (Linux/systemd)

This directory contains instructions and files for setting up a Minecraft server using native Linux systemd services. This approach offers maximum performance and control but requires more technical knowledge.

**Audience:** Intermediate to advanced users comfortable with Linux command line, systemd, and server administration.

## Prerequisites

1. **Working knowledge of command-line Linux** (these instructions are geared toward Debian/Ubuntu)
2. **Ability to open ports in your firewall/router**  
3. **Root access to your Linux server**
4. **Static IP or Dynamic DNS setup**
5. **Dedicated server recommended** (Minecraft can be CPU and memory intensive)

## What You Get

- **Maximum Performance:** Direct execution without containerization overhead
- **Full System Integration:** Native systemd service with proper logging and startup
- **Multiple Server Support:** Easy templating for running multiple game worlds
- **Advanced Management:** Direct access to all server files and configurations
- **Scheduling Support:** Built-in cron scheduling for parental controls
- **Remote Management:** RCON-based administration via included scripts

## Setup Instructions

### 1. Configure the Server

Install Java 21:

```bash
sudo apt-get update
sudo apt-get install openjdk-21-jdk-headless
```

Verify installation:

```bash
java -version
# Should show: openjdk version "21..." 
```

### 2. Create Minecraft User

Create a dedicated system user for security:

```bash
sudo adduser --system --shell /bin/bash --home /opt/minecraft --group minecraft
```

### 3. Get the Minecraft Server

**Option A:** Download manually

- Download from [https://www.minecraft.net/en-us/download/server/](https://www.minecraft.net/en-us/download/server/)
- Place as `/opt/minecraft/server/server.jar`

**Option B:** Use auto-download script

```bash
# Copy the download script
sudo cp download-server.sh /opt/minecraft/
sudo chmod +x /opt/minecraft/download-server.sh

# Create server directory and download
sudo mkdir -p /opt/minecraft/server
cd /opt/minecraft/server
sudo /opt/minecraft/download-server.sh
```

### 4. Set Permissions

```bash
sudo chown -R minecraft:minecraft /opt/minecraft
```

### 5. Initial Server Setup

Switch to minecraft user and generate initial files:

```bash
sudo su minecraft
cd /opt/minecraft/server
java -Xmx2048M -Xms256M -jar server.jar nogui
```

When it stops (EULA not accepted), edit `eula.txt`:

```bash
echo "eula=true" > eula.txt
```

Start again to generate world and configuration files:

```bash
java -Xmx2048M -Xms256M -jar server.jar nogui
```

When you see `[Server thread/INFO]: Done`, type `stop` to shut down gracefully.

### 6. Configure Server Properties

Edit `server.properties` with your preferred settings:

```bash
nano server.properties
```

**Critical settings:**

```properties
white-list=true
pvp=false                    # Recommended for family servers
server-ip=x.x.x.x     # Your server's IP
server-port=25565           # Unique port for each server
enable-rcon=true
rcon.port=25575             # Different from server-port
rcon.password=YourPassword  # Choose a secure password
```

### 7. Install systemd Service

Copy the service template:

```bash
sudo cp minecraft@.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### 8. Install and Configure mcrcon

Install build dependencies:

```bash
sudo apt-get install gcc git make
```

Build and install mcrcon:

```bash
cd /opt/minecraft
sudo git clone https://github.com/Tiiffi/mcrcon
cd mcrcon
sudo make
sudo make install
```

Configure mcrcon:

```bash
sudo cp mcrcon.conf /etc/mcrcon.conf
sudo nano /etc/mcrcon.conf
```

Edit to match your settings:

```bash
RCON_PASSWD=YourPassword    # Same as server.properties
SERVER_IP=x.x.x.x           # Your server IP
server=25575                # Your rcon.port
```

### 9. Start and Test

Start the service:

```bash
sudo systemctl start minecraft@server
```

Check status:

```bash
sudo systemctl status minecraft@server
```

Enable auto-start:

```bash
sudo systemctl enable minecraft@server
```

### 10. Test Connection

From Minecraft Java Edition:

- Multiplayer → Add Server
- Server Address: `x.x.x.x:25565` (replace with your IP:port)

### 11. Server Management

Copy management script to server directory:

```bash
sudo cp manage.sh /opt/minecraft/server/
sudo chmod +x /opt/minecraft/server/manage.sh
sudo chown minecraft:minecraft /opt/minecraft/server/manage.sh
```

Use management console:

```bash
cd /opt/minecraft/server
./manage.sh
```

Make yourself an operator:

```text
> op YourPlayerName
> Q
```

### 12. Optional: Scheduling

Add automatic start/stop schedule:

```bash
sudo crontab -e
```

Add these lines:

```bash
# Start server at 8 AM, stop at 8 PM
0 8 * * * systemctl start minecraft@server
0 20 * * * systemctl stop minecraft@server
```

## Running Multiple Servers

The systemd template makes it easy to run multiple servers:

1. **Copy server directory:**

   ```bash
   sudo cp -r /opt/minecraft/server /opt/minecraft/creative
   ```

1. **Edit new server's properties:**

   ```bash
   sudo nano /opt/minecraft/creative/server.properties
   ```

   Change:
   - `server-port=25566` (different port)
   - `rcon.port=25576` (different RCON port)
   - `level-name=creative_world` (different world name)

1. **Update mcrcon config:**

   ```bash
   sudo nano /etc/mcrcon.conf
   ```

   Add:

   ```bash
   creative=25576
   ```

1. **Start second server:**

   ```bash
   sudo systemctl start minecraft@creative
   sudo systemctl enable minecraft@creative
   ```

1. **Open additional firewall ports** for the new server port

## File Reference

- **`minecraft@.service`** - systemd service template
- **`mcrcon.conf`** - RCON configuration template  
- **`manage.sh`** - Server management script
- **`website.html`** - Parent information website template
- **`download-server.sh`** - Automatic server download script
- **`download-server.ps1`** - Windows PowerShell download script

## Troubleshooting

**Service won't start:**

```bash
sudo journalctl -u minecraft@server -f
```

**Permission errors:**

```bash
sudo chown -R minecraft:minecraft /opt/minecraft
```

**RCON connection issues:**

- Verify `enable-rcon=true` in server.properties
- Check rcon.port and rcon.password match mcrcon.conf
- Ensure RCON port is not blocked by firewall (internal use only)

**Multiple server conflicts:**

- Each server needs unique `server-port` and `rcon.port`
- Server directories must have different names
- Firewall must allow all server ports

## Advanced Features

- **Backup Scripts:** Add automated world backups via cron
- **Monitoring:** Integrate with system monitoring tools
- **Resource Limits:** Use systemd resource controls
- **Logging:** Centralized logging via journald
- **Updates:** Automated server jar updates via scripts

For the simpler Docker-based setup, see the `../quickstart/` directory.
