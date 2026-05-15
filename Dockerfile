# VICIdial Complete Installation on Ubuntu
# Multi-stage build for optimization
FROM ubuntu:22.04

LABEL maintainer="VICIdial"
LABEL description="VICIdial Complete Installation on Ubuntu 22.04"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ASTERISK_VERSION=16.30.1
ENV VICIDIAL_VERSION=latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Development tools
    build-essential \
    git \
    wget \
    curl \
    vim \
    nano \
    htop \
    tmux \
    # Web server and PHP
    apache2 \
    apache2-dev \
    php \
    php-mysql \
    php-cli \
    php-common \
    php-curl \
    php-gd \
    php-json \
    php-mbstring \
    libapache2-mod-php \
    # Database
    mariadb-server \
    mariadb-client \
    # Required libraries for Asterisk
    linux-headers-generic \
    linux-image-generic \
    libncurses5-dev \
    libssl-dev \
    libxml2-dev \
    sqlite3 \
    libsqlite3-dev \
    uuid-dev \
    libjansson-dev \
    # Audio and codec support
    libopus-dev \
    libvpx-dev \
    libtiff5-dev \
    libspandsp-dev \
    # Required utilities
    sudo \
    net-tools \
    telnet \
    unzip \
    perl \
    sox \
    lame \
    mpg123 \
    ffmpeg \
    flac \
    # Monitoring and logs
    rsyslog \
    logrotate \
    # Additional requirements
    subversion \
    ntp \
    ntpdate \
    openssh-server \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create VICIdial user and directories
RUN useradd -m -d /home/vicidial -s /bin/bash -G audio,dialout vicidial && \
    mkdir -p /home/vicidial/asterisk && \
    mkdir -p /home/vicidial/sounds && \
    mkdir -p /var/log/asterisk && \
    mkdir -p /var/run/asterisk && \
    chown -R vicidial:vicidial /home/vicidial && \
    chown -R vicidial:vicidial /var/log/asterisk && \
    chown -R vicidial:vicidial /var/run/asterisk

# Enable Apache modules required for VICIdial
RUN a2enmod rewrite && \
    a2enmod ssl && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod proxy_wstunnel

# Set MariaDB root password and initialize
RUN service mariadb start && \
    mysqladmin -u root password 'VICIdial123!' || true && \
    service mariadb stop

# Build and install Asterisk
WORKDIR /tmp
RUN wget -q http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz && \
    tar -xzf asterisk-16-current.tar.gz && \
    cd asterisk-* && \
    ./configure \
    --with-pjproject-bundled \
    --with-jansson-bundled \
    --with-bluetooth \
    --with-ssl \
    --with-srtp \
    && make menuselect.makeopts && \
    ./menuselect/menuselect \
    --enable-category MENUSELECT_ADDONS \
    --enable-category MENUSELECT_APPS \
    --enable-category MENUSELECT_CHANNELS \
    --enable-category MENUSELECT_CODECS \
    --enable-category MENUSELECT_FORMATS \
    --enable-category MENUSELECT_FUNCS \
    --enable-category MENUSELECT_TESTS \
    --enable-category MENUSELECT_UTILS \
    --enable-category MENUSELECT_RES \
    menuselect.makeopts && \
    make && \
    make install && \
    make samples && \
    make config && \
    ldconfig

# Download and install VICIdial
WORKDIR /home/vicidial
RUN git clone https://github.com/jmviana/vicidial.git vicidial-src && \
    cd vicidial-src && \
    cp -r www/* /var/www/html/ && \
    mkdir -p /var/www/html/vicidial && \
    mkdir -p /var/www/html/vicidial_api && \
    chown -R www-data:www-data /var/www/html

# Configure Apache for VICIdial
RUN cat > /etc/apache2/sites-available/vicidial.conf <<'EOF'
<VirtualHost *:80>
    ServerName localhost
    ServerAdmin admin@vicidial.org
    
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    <Directory /var/www/html/vicidial>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /var/log/apache2/vicidial_error.log
    CustomLog /var/log/apache2/vicidial_access.log combined
</VirtualHost>
EOF

RUN a2dissite 000-default && \
    a2ensite vicidial && \
    apache2ctl configtest

# Configure PHP for VICIdial
RUN cat > /etc/php/8.1/apache2/conf.d/vicidial.ini <<'EOF'
memory_limit = 512M
max_execution_time = 300
upload_max_filesize = 50M
post_max_size = 50M
display_errors = Off
error_reporting = E_ALL & ~E_NOTICE & ~E_DEPRECATED
EOF

# Create Asterisk configuration directory structure
RUN mkdir -p /etc/asterisk && \
    chown -R asterisk:asterisk /etc/asterisk && \
    chmod -R 750 /etc/asterisk

# Copy sample Asterisk configurations (will be configured by startup script)
RUN cp -r /etc/asterisk.bak/* /etc/asterisk/ 2>/dev/null || true

# Create startup script
RUN cat > /entrypoint.sh <<'EOF'
#!/bin/bash
set -e

echo "Starting VICIdial services..."

# Start MariaDB
echo "Starting MariaDB..."
service mariadb start
sleep 5

# Initialize VICIdial database if not exists
mysql -u root -p'VICIdial123!' -e "CREATE DATABASE IF NOT EXISTS vicidial CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -u root -p'VICIdial123!' -e "GRANT ALL PRIVILEGES ON vicidial.* TO 'vicidial'@'localhost' IDENTIFIED BY 'vicidial' WITH GRANT OPTION;"
mysql -u root -p'VICIdial123!' -e "FLUSH PRIVILEGES;"

# Import VICIdial database schema if available
if [ -f /home/vicidial/vicidial-src/extras/vicidial_db.sql ]; then
    echo "Importing VICIdial database schema..."
    mysql -u vicidial -pvicidial vicidial < /home/vicidial/vicidial-src/extras/vicidial_db.sql || true
fi

# Start Asterisk
echo "Starting Asterisk..."
service asterisk start
sleep 5

# Start Apache
echo "Starting Apache..."
service apache2 start

# Display service status
echo "Service Status:"
service mariadb status || true
service asterisk status || true
service apache2 status || true

echo ""
echo "======================================"
echo "VICIdial Installation Complete!"
echo "======================================"
echo "Web Interface: http://localhost"
echo "Default credentials: admin / admin"
echo "MariaDB root password: VICIdial123!"
echo "VICIdial DB user: vicidial / vicidial"
echo "======================================"

# Keep container running
tail -f /var/log/asterisk/full
EOF

RUN chmod +x /entrypoint.sh

# Create a health check script
RUN cat > /health_check.sh <<'EOF'
#!/bin/bash
# Check if all services are running
service apache2 status > /dev/null 2>&1 && \
service asterisk status > /dev/null 2>&1 && \
service mariadb status > /dev/null 2>&1 && \
echo "OK" && exit 0 || exit 1
EOF

RUN chmod +x /health_check.sh

# Expose necessary ports
# HTTP
EXPOSE 80
# HTTPS
EXPOSE 443
# Asterisk SIP UDP
EXPOSE 5060/udp
# Asterisk SIP TCP
EXPOSE 5060
# Asterisk RTP (range)
EXPOSE 10000-20000/udp
# Asterisk IAX UDP
EXPOSE 4569/udp
# MariaDB
EXPOSE 3306

# Create log directory
RUN mkdir -p /var/log/asterisk && \
    chown -R asterisk:asterisk /var/log/asterisk

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD /health_check.sh

# Set working directory
WORKDIR /home/vicidial

# Run entrypoint
ENTRYPOINT ["/entrypoint.sh"]
