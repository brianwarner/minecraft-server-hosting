# Simple script to manage your default Dockerized Minecraft server

# Start the server
docker-start:
	docker-compose up -d

# Stop the server
docker-stop:
	docker-compose down

# View server logs
docker-logs:
	docker-compose logs -f minecraft-server

# Access server console via RCON (requires mcrcon)
docker-console:
	docker exec -it minecraft-server bash -c "echo 'Install mcrcon: apt-get update && apt-get install -y mcrcon'"

# Restart the server
docker-restart:
	docker-compose restart minecraft-server

# Start multiple servers
docker-start-multi:
	docker-compose --profile multi-server up -d

# Update server jar and restart
docker-update:
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

# Backup server data
docker-backup:
	docker run --rm -v minecraft-server-hosting_minecraft-data:/data -v $(pwd):/backup alpine tar czf /backup/minecraft-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .

.PHONY: docker-start docker-stop docker-logs docker-console docker-restart docker-start-multi docker-update docker-backup
