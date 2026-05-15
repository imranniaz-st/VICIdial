# VICIdial Docker - Quick Start Guide

## 🚀 5-Minute Setup

### Option 1: Using Docker Compose (Recommended)

#### Linux/Mac:
```bash
cd /path/to/VICIdial
chmod +x build.sh
./build.sh build
./build.sh up
```

#### Windows (PowerShell):
```powershell
cd C:\path\to\VICIdial
.\build.ps1 build
.\build.ps1 up
```

#### Docker CLI (All Platforms):
```bash
# Build
docker build -t vicidial:latest .

# Run
docker run -d \
  --name vicidial \
  -p 80:80 \
  -p 443:443 \
  -p 5060:5060/udp \
  -p 5060:5060 \
  -p 10000-20000:10000-20000/udp \
  -p 4569:4569/udp \
  -p 3306:3306 \
  vicidial:latest
```

## 🔐 Access VICIdial

**URL:** http://localhost

**Credentials:**
- Username: `admin`
- Password: `admin`

## 📊 Database Access

**Host:** localhost  
**Port:** 3306  
**Database:** vicidial  
**User:** vicidial  
**Password:** vicidial  

```bash
mysql -h localhost -u vicidial -pvicidial vicidial
```

## 🛠️ Common Commands

### Using Docker Compose:
```bash
# View logs
docker-compose logs -f

# Stop services
docker-compose stop

# Start services
docker-compose start

# Rebuild (clean rebuild)
docker-compose build --no-cache

# Remove everything
docker-compose down -v
```

### Using Docker CLI:
```bash
# View logs
docker logs -f vicidial

# Access container shell
docker exec -it vicidial bash

# Stop container
docker stop vicidial

# Start container
docker start vicidial

# Remove container
docker rm vicidial
```

### Using Scripts:
```bash
# Linux/Mac - show status
./build.sh status

# Linux/Mac - view logs
./build.sh logs

# Windows - show status
.\build.ps1 status

# Windows - view logs
.\build.ps1 logs
```

## 📞 Test Your Setup

1. Log in to http://localhost
2. Go to Admin → Extensions
3. Add an extension
4. Go to Admin → Users
5. Add a user/agent
6. Test the dialer

## 🔧 Troubleshooting

### Container won't start:
```bash
# Check logs
docker logs vicidial

# Rebuild
docker-compose build --no-cache
docker-compose up -d
```

### Port already in use:
```bash
# Change port mapping in docker-compose.yml
# Change 80:80 to 8080:80 for example
docker-compose down
docker-compose up -d
```

### Database connection error:
```bash
# Check database status
docker-compose exec vicidial mysql -u root -p'VICIdial123!' -e "SHOW DATABASES;"

# Restart database
docker-compose restart mariadb
```

### Asterisk not working:
```bash
# Check Asterisk logs
docker-compose exec vicidial tail -f /var/log/asterisk/full

# Check Asterisk status
docker-compose exec vicidial asterisk -rv
```

## 📚 Key Services

| Service | Port | Access |
|---------|------|--------|
| VICIdial Web | 80 | http://localhost |
| Apache | 443 | https://localhost |
| Asterisk SIP | 5060 | sip:localhost |
| MariaDB | 3306 | localhost:3306 |

## 🗂️ File Structure

```
VICIdial/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Service orchestration
├── build.sh               # Linux/Mac helper script
├── build.ps1              # Windows helper script
├── .env.example           # Environment variables
├── README.md              # Full documentation
└── QUICKSTART.md          # This file
```

## 🔐 Security Notes ⚠️

This is for development/testing only. For production:

1. Change all default passwords
2. Use SSL/TLS certificates
3. Enable authentication
4. Use a reverse proxy (nginx)
5. Configure firewall rules
6. Run security updates
7. Use environment variables for secrets
8. Enable container logging

## 📖 Learn More

- Full documentation: [README.md](README.md)
- VICIdial: https://www.vicidial.org
- Asterisk: https://www.asterisk.org
- Docker: https://docs.docker.com

## ⚡ Performance Tips

- For production: 8GB+ RAM, 4+ vCPU
- Use SSD storage for database
- Configure MariaDB for more connections
- Monitor logs regularly
- Implement backups

## 🆘 Need Help?

1. Check logs: `docker-compose logs -f`
2. Check VICIdial logs: `docker-compose exec vicidial tail -f /var/log/asterisk/full`
3. Check database: `docker-compose exec vicidial mysql -u vicidial -pvicidial vicidial`
4. Visit https://www.vicidial.org for documentation

---

**Ready to go?** Run `./build.sh up` (or `.\build.ps1 up` on Windows) and access http://localhost!
