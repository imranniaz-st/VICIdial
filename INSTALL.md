# VICIdial Docker Installation Summary

## ✅ Complete Docker Setup for VICIdial on Ubuntu

This package contains everything needed to run VICIdial completely in Docker on Ubuntu 22.04 LTS.

**System Specs:**
- OS: Ubuntu 22.04 LTS
- vCPU: 2 cores minimum
- RAM: 4GB minimum
- Kernel: 5.15.0-177-generic #187-Ubuntu

---

## 📦 Included Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Container image definition with all VICIdial components |
| `docker-compose.yml` | Service orchestration (Asterisk, Apache, MariaDB, VICIdial) |
| `build.sh` | Helper script for Linux/Mac users |
| `build.ps1` | Helper script for Windows users |
| `.env.example` | Environment variables template |
| `.dockerignore` | Docker build optimization |
| `.gitignore` | Git version control ignore rules |
| `README.md` | Complete documentation (read this!) |
| `QUICKSTART.md` | 5-minute quick reference |
| `SETUP.md` | Detailed setup and configuration guide |
| `INSTALL.md` | This file - installation summary |

---

## 🚀 Installation Steps

### Step 1: Install Docker

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
# Logout and login for group changes to take effect
```

**Mac:**
- Install Docker Desktop from: https://www.docker.com/products/docker-desktop

**Windows:**
- Install Docker Desktop from: https://www.docker.com/products/docker-desktop
- Ensure WSL 2 is enabled (for WSL 2 backend)

### Step 2: Clone or Download VICIdial Docker Package

```bash
# Create project directory
mkdir -p ~/projects/vicidial
cd ~/projects/vicidial

# Copy the VICIdial Docker files here
# Or clone from Git repository if available
```

### Step 3: Build Docker Image

**Option A: Using Helper Script (Recommended)**

Linux/Mac:
```bash
chmod +x build.sh
./build.sh build
```

Windows (PowerShell as Administrator):
```powershell
.\build.ps1 build
```

**Option B: Manual Docker Command**
```bash
docker build -t vicidial:latest .
```

**Expected Time:** 15-30 minutes for first build (depends on internet speed)

### Step 4: Start Services

**Using Helper Script:**

Linux/Mac:
```bash
./build.sh up
```

Windows:
```powershell
.\build.ps1 up
```

**Using Docker Compose:**
```bash
docker-compose up -d
```

**Expected Time:** 1-2 minutes for services to start

### Step 5: Verify Installation

```bash
# Check container status
docker-compose ps

# Should show all services as "Up" and "healthy"
```

### Step 6: Access VICIdial

Open web browser and go to: **http://localhost**

Default Credentials:
- **Username:** admin
- **Password:** admin

---

## 📊 What Gets Installed

### Operating System
- Ubuntu 22.04 LTS

### Telephony
- Asterisk 16.30.1 (VoIP engine)
- SIP support (5060/TCP/UDP)
- RTP audio streams (10000-20000/UDP)
- IAX protocol (4569/UDP)

### Web Stack
- Apache 2.4 (web server)
- PHP 8.1 (server-side language)
- SSL/TLS support

### Database
- MariaDB (SQL database)
- VICIdial database schema

### Application
- VICIdial contact center suite
- Admin interface
- Dialer system
- Call recording
- IVR support
- CRM integration ready

---

## 🔌 Port Mappings

| Port(s) | Service | Protocol | Purpose |
|---------|---------|----------|---------|
| 80 | Apache HTTP | TCP | VICIdial web interface |
| 443 | Apache HTTPS | TCP | Secure web access |
| 5060 | Asterisk SIP | TCP/UDP | VoIP signaling |
| 10000-20000 | Asterisk RTP | UDP | Audio/Video streams |
| 4569 | Asterisk IAX | UDP | Inter-Asterisk exchange |
| 3306 | MariaDB | TCP | Database access |

---

## 🔐 Default Credentials

### VICIdial Web Interface
```
URL:      http://localhost
User:     admin
Pass:     admin
```

### VICIdial Database
```
Host:     localhost
Port:     3306
Database: vicidial
User:     vicidial
Pass:     vicidial
```

### MariaDB Root
```
User: root
Pass: VICIdial123!
```

---

## ⚠️ Important Notes

⚠️ **SECURITY WARNING:**
- Default credentials are for testing/development only
- **CHANGE ALL PASSWORDS** before production use
- Do not expose to untrusted networks
- Enable firewall rules for production
- Use SSL/TLS certificates for HTTPS
- Implement proper access controls

---

## 🛠️ Common Commands

### Status and Logs
```bash
# View service status
docker-compose ps

# View logs (all services)
docker-compose logs -f

# View specific service logs
docker-compose logs -f vicidial

# Tail logs
docker-compose logs --tail=100 -f
```

### Start/Stop Services
```bash
# Start services
docker-compose start

# Stop services
docker-compose stop

# Restart services
docker-compose restart

# Stop and remove containers
docker-compose down
```

### Access Container Shell
```bash
# Access bash shell
docker-compose exec vicidial bash

# Run command
docker-compose exec vicidial asterisk -rv

# Access database
docker-compose exec vicidial mysql -u vicidial -pvicidial vicidial
```

### Backup/Restore
```bash
# Backup database
docker-compose exec vicidial mysqldump -u vicidial -pvicidial vicidial > vicidial_backup.sql

# Restore database
docker-compose exec -T vicidial mysql -u vicidial -pvicidial vicidial < vicidial_backup.sql
```

---

## 🚨 Troubleshooting

### Container won't start
```bash
# Check detailed logs
docker-compose logs

# Rebuild image
docker-compose build --no-cache

# Restart
docker-compose restart
```

### Web interface not accessible
```bash
# Check if port 80 is in use
sudo netstat -tlnp | grep :80

# Check Apache logs
docker-compose exec vicidial tail -f /var/log/apache2/error.log

# Check if container is healthy
docker-compose ps
```

### Database connection error
```bash
# Check database status
docker-compose exec vicidial mysql -u root -p'VICIdial123!' -e "SHOW DATABASES;"

# Check database user permissions
docker-compose exec vicidial mysql -u root -p'VICIdial123!' -e "SHOW GRANTS FOR 'vicidial'@'localhost';"
```

### Asterisk/SIP not working
```bash
# Check Asterisk status
docker-compose exec vicidial asterisk -rv

# Check listening ports
docker-compose exec vicidial netstat -tlnup | grep -E "(5060|asterisk)"

# View Asterisk logs
docker-compose exec vicidial tail -f /var/log/asterisk/full
```

See **README.md** for comprehensive troubleshooting.

---

## 📚 Documentation Files

| File | Content |
|------|---------|
| **README.md** | Complete documentation, all features, troubleshooting |
| **QUICKSTART.md** | 5-minute setup, common commands, quick reference |
| **SETUP.md** | Detailed configuration, operations, advanced setup |
| **INSTALL.md** | This file - installation summary |

**Read these in order for complete understanding:**
1. INSTALL.md (you are here)
2. QUICKSTART.md (quick commands)
3. SETUP.md (detailed setup)
4. README.md (complete reference)

---

## 🎯 Next Steps After Installation

### Immediate (After successful login)
1. ✅ Change admin password
2. ✅ Explore the interface
3. ✅ Check system settings

### Configuration (First-time setup)
1. ✅ Add call centers
2. ✅ Configure campaigns
3. ✅ Add extensions
4. ✅ Add agents/users
5. ✅ Setup inbound routes
6. ✅ Configure outbound dialing

### Testing
1. ✅ Make test calls
2. ✅ Verify call recording
3. ✅ Test IVR system
4. ✅ Check database functionality

### Production Deployment
1. ✅ Backup configuration
2. ✅ Enable SSL/TLS
3. ✅ Setup monitoring
4. ✅ Configure backups
5. ✅ Security hardening
6. ✅ Performance tuning

---

## 📞 Support Resources

- **VICIdial Official:** https://www.vicidial.org
- **Asterisk Docs:** https://www.asterisk.org
- **Docker Docs:** https://docs.docker.com
- **Community:** Check VICIdial forums for support

---

## 🔄 Updating VICIdial

To get latest updates:
```bash
# Stop services
docker-compose down

# Rebuild with latest code
docker-compose build --no-cache

# Start services
docker-compose up -d
```

---

## 💾 Backup Strategy

**Regular backups are essential!**

```bash
# Daily database backup
docker-compose exec vicidial mysqldump -u vicidial -pvicidial vicidial > backup_$(date +%Y%m%d).sql

# Backup to cloud storage
# Use AWS S3, Google Cloud Storage, Dropbox, etc.
```

---

## 📋 System Requirements Checklist

- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] 2+ vCPU available
- [ ] 4GB+ RAM available
- [ ] 20GB+ disk space available
- [ ] Port 80 available (or change in docker-compose.yml)
- [ ] Port 5060 available for SIP
- [ ] Internet connection for package downloads

---

## ✨ Key Features

- ✅ Complete VICIdial installation
- ✅ Pre-configured Asterisk VoIP engine
- ✅ Apache web server with PHP
- ✅ MariaDB database
- ✅ All dependencies included
- ✅ Health monitoring
- ✅ Auto-restart on failure
- ✅ Data persistence with volumes
- ✅ Helper scripts for easy management
- ✅ Comprehensive documentation

---

## 🎓 Learning Resources

After installation, explore:
- VICIdial admin interface at http://localhost
- Asterisk documentation for advanced configs
- Docker documentation for container management
- VICIdial community forums for support

---

## 📝 Version Information

- **Base OS:** Ubuntu 22.04 LTS
- **Asterisk:** 16.30.1
- **Apache:** 2.4
- **PHP:** 8.1
- **MariaDB:** Latest
- **VICIdial:** Latest
- **Kernel:** 5.15.0-177-generic

---

## 🏁 Quick Start Command

**One-liner to build and start (after installing Docker):**

```bash
docker-compose up -d && docker-compose logs -f
```

Then access: **http://localhost**

---

**🎉 That's it! VICIdial is now running in Docker.**

For questions or issues, refer to the documentation files or visit https://www.vicidial.org

---

**Created:** May 2026  
**For:** Ubuntu 22.04 LTS, 2vCPU, 4GB RAM systems  
**Kernel:** 5.15.0-177-generic
