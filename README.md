# Minecraft Server Hosting

This is the easiest way to run your own Minecraft server! Perfect for hosting survival worlds, creative builds, or mini-game servers for your friends and family.

**Who this is for:** Anyone who wants to run Minecraft servers without dealing with complex technical setup.

**Note:** These instructions are for [Minecraft Java Edition](https://www.minecraft.net/en-us/store/minecraft-java-edition/) only. At the time of writing, there are no options to self-host Minecraft Bedrock Edition.

## What You Get

- 🌍 **Instant Minecraft Worlds:** Create new survival or creative worlds in minutes
- 🔄 **Always Up-to-Date:** Automatically uses the latest Minecraft server version
- 🎮 **Multiple Worlds:** Run different worlds simultaneously (survival, creative, mini-games)
- 🛡️ **Safe & Isolated:** Each world runs independently and securely
- 🌐 **Friends Can Join:** Accessible to anyone on your local network
- � **Easy Management:** Simple commands to create, start, stop, and backup worlds
- 💾 **World Persistence:** Your builds and progress are automatically saved

## Prerequisites

- **Docker Desktop** installed on your computer
  - [Download for Windows](https://docs.docker.com/desktop/install/windows-install/)
  - [Download for Mac](https://docs.docker.com/desktop/install/mac-install/)
  - [Download for Linux](https://docs.docker.com/desktop/install/linux-install/)
- **Basic comfort with command line**
- **Router access** (optional, for internet access)

## How to Start a Default Survival World

The fastest way to get a standard survival world running:

1. **Create your world settings:**

   ```bash
   cp .env.example .env
   ```

2. **Start your world:**

   ```bash
   docker-compose up -d
   ```

3. **That's it!** Your survival world is now running and accessible at:
   - **Local network:** `<your-computer-ip>:25565`
   - **Same computer:** `localhost:25565`

Your world will have:

- Difficulty: Easy
- Game mode: Survival  
- PvP: Disabled (friendly for families)
- Max players: 20
- World name: "world"

## How to Stop a World

```bash
docker-compose down
```

This safely shuts down your world and saves all player progress.

## How to Delete a World

⚠️ **Warning:** This permanently deletes all builds, items, and player data!

```bash
# Stop the world first
docker-compose down

# Delete all world data
docker-compose down -v
```

## How to Backup a World

### Quick Backup

```bash
# Create a backup file with today's date (replace "my-minecraft-server" with your LEVEL_NAME)
docker run --rm -v minecraft-server-hosting_my-minecraft-server-data:/data -v "$(pwd)":/backup ubuntu tar czf /backup/my-world-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore from Backup

```bash
# Stop the world first
docker-compose down

# Restore from backup file (replace "my-minecraft-server" with your LEVEL_NAME)
docker run --rm -v minecraft-server-hosting_my-minecraft-server-data:/data -v "$(pwd)":/backup ubuntu tar xzf /backup/my-world-backup-YYYYMMDD.tar.gz -C /data

# Start the world again
docker-compose up -d
```

## How to Create a New World

### Option 1: Different World Name (keeps old world)

1. **Edit your world settings:**

   ```bash
   nano .env  # Linux/Mac
   notepad .env  # Windows
   ```

2. **Change the world name:**

   ```bash
   LEVEL_NAME=my-new-world
   ```

3. **Restart to create the new world:**

   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Option 2: Fresh Start (deletes old world)

```bash
# Stop and delete current world
docker-compose down -v

# Start fresh
docker-compose up -d
```

## How to Run Multiple Worlds at the Same Time

You can run different types of worlds simultaneously! Here's how to set up multiple worlds:

### Example: Survival + Creative Worlds

1. **Create settings for your creative world:**

   ```bash
   cp .env.example .env.creative
   ```

2. **Edit `.env.creative` for creative mode:**

   ```bash
   # Give it a unique world name and port
   LEVEL_NAME=creative-world
   SERVER_PORT=25566
   RCON_PORT=25576
   
   # Creative world settings
   GAMEMODE=creative
   DIFFICULTY=peaceful
   PVP=false
   MOTD=Creative Building Server
   ```

3. **Create a second docker-compose file:**

   ```bash
   cp docker-compose.yml docker-compose.creative.yml
   ```

4. **Edit `docker-compose.creative.yml` to use the creative settings:**

   ```yaml
   services:
     minecraft-server:
       env_file:
         - .env.creative
       ports:
         - "25566:25565"  # Different port
         - "25576:25575"  # Different RCON port
       volumes:
         - creative-world-data:/opt/minecraft/server
   
   volumes:
     creative-world-data:
   ```

5. **Start both worlds:**

   ```bash
   # Start survival world (port 25565)
   docker-compose up -d
   
   # Start creative world (port 25566)  
   docker-compose -f docker-compose.creative.yml up -d
   ```

6. **Connect to different worlds:**
   - **Survival:** `<your-ip>:25565`
   - **Creative:** `<your-ip>:25566`

### Example: Multiple Themed Worlds

You can create as many worlds as you want:

```bash
# Mini-games world
cp .env.example .env.minigames
# Edit: LEVEL_NAME=minigames-hub, SERVER_PORT=25567, etc.

# Hardcore world  
cp .env.example .env.hardcore
# Edit: LEVEL_NAME=hardcore-survival, SERVER_PORT=25568, HARDCORE=true, etc.

# Start all worlds
docker-compose up -d                                           # Main world
docker-compose -f docker-compose.creative.yml up -d            # Creative  
docker-compose -f docker-compose.minigames.yml up -d           # Mini-games
docker-compose -f docker-compose.hardcore.yml up -d            # Hardcore
```

## Customizing Your World

### Easy Settings (.env file)

Edit your `.env` file to customize your world:

```bash
# World basics
LEVEL_NAME=my-awesome-world
MOTD=Welcome to My Server!
MAX_PLAYERS=10

# Gameplay
GAMEMODE=survival          # survival, creative, adventure, spectator
DIFFICULTY=normal          # peaceful, easy, normal, hard
HARDCORE=false            # true = permanent death
PVP=true                  # true = players can fight each other

# World generation
LEVEL_TYPE=minecraft:normal    # normal, flat, large_biomes, etc.
LEVEL_SEED=12345678           # Leave empty for random

# Server behavior  
SPAWN_PROTECTION=16       # Blocks around spawn where only ops can build
VIEW_DISTANCE=10          # How far players can see (higher = more lag)
```

Apply changes by restarting your world:

```bash
docker-compose down
docker-compose up -d
```

### Advanced Settings

For fine-grained control, you can access all Minecraft server settings through the `.env` file. See `.env.example` for the complete list of available options.

## Managing Your World

### View Server Logs

```bash
# See what's happening in your world
docker-compose logs -f

# See recent activity
docker-compose logs --tail=20
```

### Run Admin Commands

1. **Connect to your world's console:**

   ```bash
   docker exec -it $(docker-compose ps -q) mcrcon -H localhost -P 25575 -p minecraft
   ```

2. **Make yourself an admin:**

   ```text
   op YourPlayerName
   ```

3. **Other useful commands:**

   ```text
   list                    # See who's online
   weather clear           # Clear weather
   time set day           # Set time to day
   gamemode creative YourPlayerName  # Change player's game mode
   teleport YourPlayerName ~ ~10 ~   # Teleport player up 10 blocks
   ```

4. **Exit console:**

   ```text
   quit
   ```

### Check World Performance

```bash
# See memory and CPU usage
docker stats $(docker-compose ps -q)

# See server status
docker ps
```

## Connecting to Your World

### Local Network (Friends at Your House)

1. **Find your computer's IP address:**
   - **Windows:** Open Command Prompt, type `ipconfig`
   - **Mac:** System Preferences → Network
   - **Linux:** Terminal, type `ip addr`

2. **In Minecraft Java Edition:**
   - Multiplayer → Add Server
   - Server Address: `192.168.1.xxx:25565` (replace xxx with your IP)

### Internet Access (Friends from Anywhere)

1. **Forward port 25565 in your router** to your computer
   - Log into your router's admin page
   - Find "Port Forwarding" or "Virtual Servers"
   - Forward external port 25565 to your computer's IP:25565

2. **Find your external IP:** Visit [whatismyipaddress.com](https://whatismyipaddress.com)

3. **Share with friends:** `your-external-ip:25565`

⚠️ **Security Note:** Opening ports to the internet has security implications. Only do this if you understand the risks.

## Common Issues & Solutions

### "Connection refused" Error

- **Check if world is running:** `docker ps`
- **Check firewall:** Ensure port 25565 is allowed
- **Windows networks:** Change from Public to Private network in Settings

### World Won't Start

```bash
# Check what went wrong
docker-compose logs

# Try rebuilding
docker-compose down
docker-compose up -d --build
```

### Out of Memory

```bash
# Edit .env file to increase memory
MEMORY_MAX=4G

# Restart world
docker-compose down
docker-compose up -d
```

### Can't Connect from Same Computer

Use `localhost:25565` instead of your IP address.

## File Locations & Advanced Access

### Access Your World Files Directly

```bash
# Open a terminal inside your world
docker exec -it $(docker-compose ps -q) bash

# List world files
docker exec $(docker-compose ps -q) ls -la /opt/minecraft/server/

# Copy files out (e.g., for external map viewers)
docker cp $(docker-compose ps -q):/opt/minecraft/server/world ./world-backup
```

### Included Management Scripts

- **Windows:** `minecraft-docker.ps1` - PowerShell management script
- **Linux/Mac:** `start-server.sh` - Bash management script

## Getting Help

### Quick Diagnostics

```bash
# Is your world running?
docker ps

# What's in the logs?
docker-compose logs --tail=50

# What's the server saying?
docker exec -it $(docker-compose ps -q) mcrcon -H localhost -P 25575 -p minecraft
```

### Reset Everything (⚠️ Deletes All Worlds)

```bash
docker-compose down -v
docker system prune -f
```

## Advanced Setup Options

If you need more control, performance, or want to run on a dedicated Linux server without Docker, check out the **[Advanced Linux Setup →](advanced/README.md)**

The advanced setup provides:

- **Maximum performance** (no container overhead)
- **Native Linux systemd integration** with scheduling
- **Template-based multi-server management**
- **Advanced security configurations**
- **Production-ready deployment options**

**Best for:** Dedicated servers, advanced users, or production deployments where maximum performance is required.

## License & Contributing

This project is open source and available under the MIT License.

- Feel free to submit issues, improvements, or additional features
- Both basic and advanced approaches are actively maintained
- Star the repo if you find it helpful! ⭐

---

**Happy crafting!**
