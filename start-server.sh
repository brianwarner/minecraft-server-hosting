#!/bin/bash

#!/bin/bash

# Always create/update server.properties from environment variables
echo "Creating server.properties from environment variables..."
cat > server.properties << EOF
# Network settings
server-port=${SERVER_PORT:-25565}
server-ip=${SERVER_IP:-}
rcon.port=${RCON_PORT:-25575}
rcon.password=${RCON_PASSWORD:-minecraft}
enable-rcon=${ENABLE_RCON:-true}
query.port=${QUERY_PORT:-25565}
enable-query=${ENABLE_QUERY:-false}

# World settings
level-name=${LEVEL_NAME:-world}
level-seed=${LEVEL_SEED:-}
level-type=${LEVEL_TYPE:-minecraft:normal}
generator-settings=${GENERATOR_SETTINGS:-{}}
generate-structures=${GENERATE_STRUCTURES:-true}
max-world-size=${MAX_WORLD_SIZE:-29999984}

# Game settings
gamemode=${GAMEMODE:-survival}
difficulty=${DIFFICULTY:-easy}
hardcore=${HARDCORE:-false}
pvp=${PVP:-false}
force-gamemode=${FORCE_GAMEMODE:-false}
max-players=${MAX_PLAYERS:-20}
spawn-monsters=${SPAWN_MONSTERS:-true}
spawn-animals=${SPAWN_ANIMALS:-true}
spawn-npcs=${SPAWN_NPCS:-true}
allow-nether=${ALLOW_NETHER:-true}
allow-flight=${ALLOW_FLIGHT:-false}

# Player management
white-list=${WHITE_LIST:-false}
enforce-whitelist=${ENFORCE_WHITELIST:-false}
online-mode=${ONLINE_MODE:-true}
prevent-proxy-connections=${PREVENT_PROXY_CONNECTIONS:-false}
player-idle-timeout=${PLAYER_IDLE_TIMEOUT:-0}

# Performance settings
view-distance=${VIEW_DISTANCE:-10}
simulation-distance=${SIMULATION_DISTANCE:-10}
max-tick-time=${MAX_TICK_TIME:-60000}
network-compression-threshold=${NETWORK_COMPRESSION_THRESHOLD:-256}
max-chained-neighbor-updates=${MAX_CHAINED_NEIGHBOR_UPDATES:-1000000}
sync-chunk-writes=${SYNC_CHUNK_WRITES:-true}
use-native-transport=${USE_NATIVE_TRANSPORT:-true}

# Server behavior
motd=${MOTD:-A Minecraft Server}
enable-status=${ENABLE_STATUS:-true}
enable-command-block=${ENABLE_COMMAND_BLOCK:-false}
enable-jmx-monitoring=${ENABLE_JMX_MONITORING:-false}
broadcast-console-to-ops=${BROADCAST_CONSOLE_TO_OPS:-true}
broadcast-rcon-to-ops=${BROADCAST_RCON_TO_OPS:-true}
op-permission-level=${OP_PERMISSION_LEVEL:-4}
function-permission-level=${FUNCTION_PERMISSION_LEVEL:-2}

# World protection
spawn-protection=${SPAWN_PROTECTION:-16}
rate-limit=${RATE_LIMIT:-0}

# Resource packs
resource-pack=${RESOURCE_PACK:-}
resource-pack-sha1=${RESOURCE_PACK_SHA1:-}
resource-pack-prompt=${RESOURCE_PACK_PROMPT:-}
require-resource-pack=${REQUIRE_RESOURCE_PACK:-false}

# Advanced settings
log-ips=${LOG_IPS:-true}
hide-online-players=${HIDE_ONLINE_PLAYERS:-false}
bug-report-link=${BUG_REPORT_LINK:-}
text-filtering-config=${TEXT_FILTERING_CONFIG:-}

# Additional properties (auto-managed)
accepts-transfers=false
enforce-secure-profile=true
entity-broadcast-range-percentage=100
initial-disabled-packs=
initial-enabled-packs=vanilla
pause-when-empty-seconds=60
region-file-compression=deflate
resource-pack-id=
text-filtering-version=0
EOF

echo "Server properties configured from environment variables"

# Accept EULA if not already done
if [ ! -f "eula.txt" ]; then
    echo "Accepting Minecraft EULA..."
    echo "eula=true" > eula.txt
fi

# Download server jar if needed
if [ -f "/opt/minecraft/download-server.sh" ]; then
    /opt/minecraft/download-server.sh
fi

# Start the Minecraft server
echo "Starting Minecraft server..."
echo "Memory: ${MEMORY_MIN} to ${MEMORY_MAX}"
echo "Server will be available on port ${SERVER_PORT}"
echo "RCON available on port ${RCON_PORT}"

exec java -Xms${MEMORY_MIN} -Xmx${MEMORY_MAX} \
    -XX:+UseG1GC \
    -XX:ParallelGCThreads=2 \
    -XX:MinHeapFreeRatio=5 \
    -XX:MaxHeapFreeRatio=10 \
    -jar server.jar nogui
