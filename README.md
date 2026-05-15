# VICIdial Complete Docker Installation

Complete Docker setup for VICIdial on Ubuntu 22.04 LTS

## System Requirements

- **OS**: Ubuntu 22.04 LTS (or compatible)
- **CPU**: 2vCPU or higher
- **RAM**: 4GB or higher
- **Storage**: 20GB or higher
- **Kernel**: 5.15.0+ (for optimal performance)

## What's Included

This Docker installation includes:

- **Ubuntu 22.04 LTS** base image
- **Asterisk 16.30.1** VoIP engine
- **Apache 2.4** web server with PHP support
- **MariaDB** relational database
- **VICIdial** contact center suite
- **All dependencies** pre-installed and configured

## Installation

### Prerequisites

```bash
# Install Docker and Docker Compose
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

### Build and Deploy

```bash
# Clone or navigate to the repository
cd /path/to/VICIdial

# Build the Docker image
docker build -t vicidial:latest .

# Or use Docker Compose for easier management
docker-compose up -d
```

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f vicidial

# Stop services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v
```

### Using Docker directly

```bash
# Run the container
docker run -d \
  --name vicidial-server \
  -p 80:80 \
  -p 443:443 \
  -p 5060:5060 \
  -p 5060:5060/udp \
  -p 10000-20000:10000-20000/udp \
  -p 4569:4569/udp \
  -p 3306:3306 \
  -v vicidial_db:/var/lib/mysql \
  -v vicidial_logs:/var/log \
  vicidial:latest

# View logs
docker logs -f vicidial-server
```

## Default Access Credentials

```
Web Interface URL: http://localhost
Admin Username: admin
Admin Password: admin

MariaDB Root User: root
MariaDB Root Password: VICIdial123!

VICIdial DB User: vicidial
VICIdial DB Password: vicidial
```

## Port Mappings

| Service | Port(s) | Protocol | Purpose |
|---------|---------|----------|---------|
| Apache HTTP | 80 | TCP | Web interface |
| Apache HTTPS | 443 | TCP | Secure web access |
| Asterisk SIP | 5060 | TCP/UDP | VoIP signaling |
| Asterisk RTP | 10000-20000 | UDP | Audio/Video streams |
| Asterisk IAX | 4569 | UDP | Inter-Asterisk exchange |
| MariaDB | 3306 | TCP | Database access |

## Volumes

The Docker Compose setup uses named volumes for data persistence:

- `vicidial_db`: MariaDB database files
- `vicidial_asterisk`: Asterisk configuration files
- `vicidial_www`: VICIdial web application files
- `vicidial_logs`: Application and system logs

## Configuration

### Access the Container

```bash
# Using Docker Compose
docker-compose exec vicidial bash

# Using Docker
docker exec -it vicidial-server bash
```

### Asterisk Configuration

Asterisk configs are located at `/etc/asterisk/` inside the container:

```bash
docker-compose exec vicidial bash
cd /etc/asterisk
ls -la
```

### PHP Configuration

PHP settings for VICIdial are in `/etc/php/8.1/apache2/conf.d/vicidial.ini`

### MariaDB Configuration

To connect to the database:

```bash
# From host machine
mysql -h localhost -u vicidial -pvicidial vicidial

# From inside container
docker-compose exec vicidial mysql -u vicidial -pvicidial vicidial
```

## Logs

View logs from the services:

```bash
# VICIdial/Docker logs
docker-compose logs -f vicidial

# Asterisk logs (inside container)
docker-compose exec vicidial tail -f /var/log/asterisk/full

# Apache logs
docker-compose exec vicidial tail -f /var/log/apache2/access.log
```

## Backup and Restore

### Backup Database

```bash
docker-compose exec vicidial mysqldump -u vicidial -pvicidial vicidial > vicidial_backup.sql
```

### Restore Database

```bash
docker-compose exec -T vicidial mysql -u vicidial -pvicidial vicidial < vicidial_backup.sql
```

### Backup All Data

```bash
# Backup all volumes
docker run --rm \
  -v vicidial_db:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/vicidial_backup.tar.gz -C / data
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs -f

# Verify image exists
docker images | grep vicidial

# Rebuild image
docker-compose build --no-cache
```

### Services not responding

```bash
# Check if services are running
docker-compose exec vicidial service apache2 status
docker-compose exec vicidial service asterisk status
docker-compose exec vicidial service mariadb status

# Restart services
docker-compose restart
```

### Database connection issues

```bash
# Check MySQL/MariaDB
docker-compose exec vicidial mysql -u root -p'VICIdial123!' -e "SHOW DATABASES;"

# Check permissions
docker-compose exec vicidial mysql -u root -p'VICIdial123!' -e "SHOW GRANTS FOR 'vicidial'@'localhost';"
```

### Audio/SIP issues

```bash
# Check Asterisk status
docker-compose exec vicidial asterisk -rv

# Check listening ports
docker-compose exec vicidial netstat -tlnup | grep -E "(5060|asterisk)"
```

## Performance Tuning

For production environments with higher call volume:

1. **Increase RAM**: Set to 8GB+ in docker-compose.yml
2. **Increase vCPU**: Use 4+ cores
3. **Database optimization**: Configure MariaDB for higher connections
4. **Asterisk tuning**: Adjust RTP buffer sizes
5. **Volume mounts**: Use local SSD storage for database

## Security Recommendations

⚠️ **IMPORTANT**: This is a development/test setup. For production:

1. Change all default passwords
2. Use SSL/TLS certificates
3. Configure firewall rules
4. Use strong database passwords
5. Enable MariaDB authentication
6. Configure Asterisk ACLs
7. Use reverse proxy (nginx)
8. Enable container network isolation
9. Regular security updates
10. Implement monitoring and alerting

## Advanced Configuration

### Enable SIP TLS

Edit Asterisk configuration:
```bash
docker-compose exec vicidial nano /etc/asterisk/sip.conf
```

### Configure for Multiple Extensions

Modify `/var/www/html/vicidial/admin.php` and adjust Asterisk users configuration.

### Integration with External SIP Providers

Configure trunks in `/etc/asterisk/sip.conf` and dialplan in `/etc/asterisk/extensions.conf`.

## Support and Resources

- **VICIdial Official**: https://www.vicidial.org
- **Asterisk Documentation**: https://www.asterisk.org
- **Docker Documentation**: https://docs.docker.com

## License

VICIdial is released under the AGPLv2+ license. See VICIdial documentation for details.

## Maintenance

### Regular Updates

```bash
# Update Docker image
docker-compose pull
docker-compose build --no-cache
docker-compose up -d
```

### Health Check

The container includes a health check that runs every 30 seconds. Check status:

```bash
docker-compose ps
```

### Logs Rotation

Logs are automatically rotated via logrotate configuration inside the container.

## Next Steps

1. Access the web interface at `http://localhost`
2. Log in with admin credentials
3. Configure call centers and campaigns
4. Add extensions and agents
5. Configure inbound/outbound routes
6. Test calling functionality
7. Implement monitoring and backups

---

**Created for**: Ubuntu 22.04 LTS with 2vCPU, 4GB RAM
**Kernel**: 5.15.0-177-generic #187-Ubuntu
**Date**: May 2026
