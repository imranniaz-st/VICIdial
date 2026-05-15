# VICIdial Docker Installation - Complete Setup Guide

## 📋 Project Structure

```
VICIdial/
│
├── Dockerfile                 # Docker image configuration - installs all VICIdial components
├── docker-compose.yml         # Docker Compose configuration - orchestrates services
├── .dockerignore              # Files to exclude from Docker build context
├── .env.example               # Environment variables template
│
├── build.sh                   # Linux/Mac helper script for build/deploy
├── build.ps1                  # Windows PowerShell helper script
│
├── README.md                  # Comprehensive documentation and troubleshooting
├── QUICKSTART.md              # Quick reference guide
├── SETUP.md                   # This file
│
└── docs/ (optional)
    └── troubleshooting.md     # Advanced troubleshooting guide
```

## 🎯 What's Installed

### Core Components:
- **Ubuntu 22.04 LTS** - Base operating system
- **Asterisk 16.30.1** - Open-source VoIP engine
- **Apache 2.4** - Web server with SSL/TLS support
- **PHP 8.1** - Server-side scripting language
- **MariaDB** - SQL database server
- **VICIdial** - Contact center application

### Features:
- Pre-configured VoIP infrastructure
- Database with user/extension management
- Web admin interface
- SIP signaling (5060)
- RTP audio streaming (10000-20000)
- IAX protocol support (4569)
- Full logging and monitoring
- Health checks and auto-restart

## 🚀 Getting Started

### Step 1: Prerequisites

```bash
# Linux
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER

# Mac
# Install Docker Desktop from https://www.docker.com/products/docker-desktop

# Windows
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
```

### Step 2: Build the Image

#### Linux/Mac:
```bash
cd /path/to/VICIdial
chmod +x build.sh
./build.sh build
```

#### Windows (PowerShell as Administrator):
```powershell
cd C:\path\to\VICIdial
.\build.ps1 build
```

#### Manual Docker:
```bash
docker build -t vicidial:latest .
```

**Expected:** Image builds in 15-30 minutes (first build takes longer)

### Step 3: Start Services

#### Using Script:
```bash
./build.sh up          # Linux/Mac
.\build.ps1 up         # Windows
```

#### Using Docker Compose:
```bash
docker-compose up -d
```

**Expected:** All services start within 1-2 minutes

### Step 4: Verify Installation

```bash
# Check service status
docker-compose ps

# Check logs
docker-compose logs -f

# Access web interface
# Open browser: http://localhost
# Login: admin / admin
```

## 📊 Service Ports & Access

| Service | Port(s) | Protocol | Purpose | Access |
|---------|---------|----------|---------|--------|
| HTTP | 80 | TCP | Web interface | http://localhost |
| HTTPS | 443 | TCP | Secure web | https://localhost |
| SIP | 5060 | TCP/UDP | SIP signaling | sip:localhost |
| RTP | 10000-20000 | UDP | Audio/video | Auto-allocated |
| IAX | 4569 | UDP | Inter-Asterisk | Auto-allocated |
| MySQL | 3306 | TCP | Database | localhost:3306 |

## 🔑 Credentials

### VICIdial Web Admin
```
URL:      http://localhost
Username: admin
Password: admin
```

### Database Access
```
Host:     localhost
Port:     3306
Database: vicidial
Username: vicidial
Password: vicidial
Root:     root / VICIdial123!
```

## 🛠️ Configuration Files

### Dockerfile
Location: `./Dockerfile`  
Purpose: Defines container image with all VICIdial components  
Key Sections:
- System package installation
- Build tools and development headers
- Asterisk compilation
- VICIdial application setup
- Service configuration

### docker-compose.yml
Location: `./docker-compose.yml`  
Purpose: Orchestrates multi-container setup  
Includes:
- Service definitions
- Port mappings
- Volume persistence
- Environment variables
- Health checks
- Auto-restart policy

### .env.example
Location: `./.env.example`  
Purpose: Template for environment variables  
Usage:
```bash
cp .env.example .env
# Edit .env with your settings
docker-compose --env-file .env up -d
```

## 💾 Data Persistence

All data is stored in Docker named volumes:

- `vicidial_db` → MariaDB database files
- `vicidial_asterisk` → Asterisk configurations
- `vicidial_www` → Web application files
- `vicidial_logs` → Application logs

Volumes survive container restarts.

## 📈 Common Operations

### Start/Stop Services
```bash
docker-compose start    # Start existing containers
docker-compose stop     # Stop running containers
docker-compose restart  # Restart services
docker-compose pause    # Pause services
docker-compose unpause  # Resume services
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f vicidial

# Follow last 100 lines
docker-compose logs --tail=100 -f
```

### Execute Commands
```bash
# Access shell
docker-compose exec vicidial bash

# Run command
docker-compose exec vicidial asterisk -rv

# Database commands
docker-compose exec vicidial mysql -u vicidial -pvicidial vicidial
```

### Backup Operations
```bash
# Backup database
docker-compose exec vicidial mysqldump -u vicidial -pvicidial vicidial > backup.sql

# Restore database
docker-compose exec -T vicidial mysql -u vicidial -pvicidial vicidial < backup.sql

# Backup volumes
docker run --rm \
  -v vicidial_db:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/vicidial_backup.tar.gz -C / data
```

## 🔧 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs vicidial

# Verify image exists
docker images | grep vicidial

# Rebuild without cache
docker-compose build --no-cache

# Check disk space
df -h
```

### Services Not Running
```bash
# Check status
docker-compose ps

# Check service logs
docker-compose exec vicidial service asterisk status
docker-compose exec vicidial service apache2 status
docker-compose exec vicidial service mariadb status

# Restart
docker-compose restart
```

### Port Already in Use
```bash
# Find process using port
netstat -tlnp | grep 80
lsof -i :80

# Change port in docker-compose.yml
# Change "80:80" to "8080:80"
```

### Database Connection Issues
```bash
# Test database
docker-compose exec vicidial mysql -u vicidial -pvicidial vicidial -e "SELECT VERSION();"

# Check permissions
docker-compose exec vicidial mysql -u root -p'VICIdial123!' -e "SHOW GRANTS FOR 'vicidial'@'localhost';"

# Restart database
docker-compose restart mariadb
```

### Web Interface Not Accessible
```bash
# Check Apache
docker-compose exec vicidial apache2ctl status

# Check logs
docker-compose exec vicidial tail -f /var/log/apache2/error.log

# Restart Apache
docker-compose exec vicidial systemctl restart apache2
```

### SIP/Asterisk Issues
```bash
# Check Asterisk
docker-compose exec vicidial asterisk -rv

# Check SIP status
docker-compose exec vicidial asterisk -rx "sip show peers"

# Check logs
docker-compose exec vicidial tail -f /var/log/asterisk/full
```

## 📚 Helper Scripts

### build.sh (Linux/Mac)
Commands:
- `./build.sh build` - Build image
- `./build.sh rebuild` - Rebuild without cache
- `./build.sh up` - Start services
- `./build.sh down` - Stop services
- `./build.sh rm` - Remove containers
- `./build.sh logs` - View logs
- `./build.sh clean` - Clean everything
- `./build.sh status` - Show status
- `./build.sh help` - Show help

### build.ps1 (Windows)
Same commands as build.sh but for PowerShell

## 🔒 Security Checklist

- [ ] Change default passwords
- [ ] Configure SSL/TLS certificates
- [ ] Enable authentication
- [ ] Setup firewall rules
- [ ] Configure backup strategy
- [ ] Monitor resource usage
- [ ] Regular security updates
- [ ] Implement monitoring/alerting
- [ ] Use environment variables for secrets
- [ ] Enable container logging

## 📖 Additional Resources

- **VICIdial Documentation**: https://www.vicidial.org
- **Asterisk Documentation**: https://www.asterisk.org
- **Docker Documentation**: https://docs.docker.com
- **Docker Compose**: https://docs.docker.com/compose

## 🐛 Support

1. Check **README.md** for comprehensive documentation
2. Check **QUICKSTART.md** for quick reference
3. Review **troubleshooting** section above
4. Check Docker/service logs: `docker-compose logs -f`
5. Visit https://www.vicidial.org for community support

## ✅ Verification Checklist

- [ ] Docker and Docker Compose installed
- [ ] Image built successfully
- [ ] Containers running (`docker-compose ps`)
- [ ] Web interface accessible (http://localhost)
- [ ] Can log in (admin/admin)
- [ ] Database responding
- [ ] Asterisk running

## 🎯 Next Steps

After successful installation:

1. **Initial Configuration**
   - Change admin password
   - Configure system settings
   - Add time zones

2. **Setup Call Center**
   - Add campaigns
   - Configure inbound/outbound routes
   - Setup extensions/agents

3. **Testing**
   - Make test calls
   - Verify recording
   - Test IVR functions

4. **Production Deployment**
   - Enable SSL/TLS
   - Configure backups
   - Setup monitoring
   - Implement security hardening

---

**Created for**: Ubuntu 22.04 LTS, 2vCPU, 4GB RAM  
**Kernel**: 5.15.0-177-generic  
**Last Updated**: May 2026
