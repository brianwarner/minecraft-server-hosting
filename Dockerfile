# Minecraft Server Docker Image
# Based on OpenJDK 21 for optimal Minecraft performance

FROM openjdk:21-jdk-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y wget curl unzip netcat-openbsd jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create minecraft user and directories
RUN useradd -m -u 1000 minecraft && \
    mkdir -p /opt/minecraft/server && \
    chown -R minecraft:minecraft /opt/minecraft

# Set working directory
WORKDIR /opt/minecraft/server

# Switch to minecraft user
USER minecraft

# Expose ports (using default values, actual ports come from .env)
EXPOSE 25565 25575

# Download Minecraft server jar (you'll need to update this URL periodically)
# Users should mount their own server.jar or we'll download the latest
COPY --chown=minecraft:minecraft download-server.sh /opt/minecraft/
RUN chmod +x /opt/minecraft/download-server.sh

# Copy startup script
COPY --chown=minecraft:minecraft start-server.sh /opt/minecraft/
RUN chmod +x /opt/minecraft/start-server.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD nc -z localhost 25565 || exit 1

# Start the server
CMD ["/opt/minecraft/start-server.sh"]
