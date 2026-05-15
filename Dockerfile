FROM ubuntu:22.04

LABEL maintainer="VICIdial"
ENV DEBIAN_FRONTEND=noninteractive
ENV ASTERISK_VERSION=18.26.4

# =========================
# 1. SYSTEM DEPENDENCIES
# =========================
RUN apt-get update && apt-get install -y \
    build-essential git wget curl vim nano htop tmux \
    linux-headers-generic \
    libssl-dev libncurses5-dev libncursesw5-dev \
    libxml2-dev libsqlite3-dev uuid-dev \
    libjansson-dev libedit-dev \
    libsrtp2-dev libopus-dev libogg-dev \
    sox ffmpeg lame mpg123 flac \
    && rm -rf /var/lib/apt/lists/*

# =========================
# 2. WEB + DB STACK
# =========================
RUN apt-get update && apt-get install -y \
    apache2 apache2-dev libapache2-mod-php \
    php php-cli php-mysql php-curl php-gd php-mbstring \
    mariadb-server mariadb-client \
    net-tools unzip perl sudo \
    && rm -rf /var/lib/apt/lists/*

# =========================
# 3. USER SETUP
# =========================
RUN useradd -m -s /bin/bash vicidial && \
    mkdir -p /home/vicidial/{asterisk,sounds} && \
    mkdir -p /var/log/asterisk /var/run/asterisk && \
    chown -R vicidial:vicidial /home/vicidial

# =========================
# 4. APACHE MODULES
# =========================
RUN a2enmod rewrite ssl proxy proxy_http proxy_wstunnel

# =========================
# 5. DOWNLOAD ASTERISK
# =========================
WORKDIR /tmp

RUN wget -O asterisk.tar.gz \
    http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz

# =========================
# 6. EXTRACT
# =========================
RUN tar -xzf asterisk.tar.gz && rm asterisk.tar.gz

# =========================
# 7. BUILD ASTERISK (FIXED PATH - NO WILDCARD)
# =========================
RUN set -eux; \
    cd /tmp/asterisk-${ASTERISK_VERSION}; \
    ./configure \
        --with-pjproject-bundled \
        --with-jansson-bundled \
        --with-srtp; \
    make menuselect.makeopts; \
    make -j$(nproc); \
    make install; \
    make samples; \
    make config; \
    ldconfig

# =========================
# 8. VICIDIAL SOURCE
# =========================
WORKDIR /home/vicidial

RUN git clone https://github.com/jmviana/vicidial.git vicidial-src && \
    cp -r vicidial-src/www/* /var/www/html/ && \
    chown -R www-data:www-data /var/www/html

# =========================
# 9. APACHE CONFIG
# =========================
RUN cat > /etc/apache2/sites-available/vicidial.conf <<'EOF'
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/vicidial_error.log
    CustomLog /var/log/apache2/vicidial_access.log combined
</VirtualHost>
EOF

RUN a2dissite 000-default && a2ensite vicidial

# =========================
# 10. PHP CONFIG (SAFE PATH)
# =========================
RUN PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') && \
    mkdir -p /etc/php/${PHP_VER}/apache2/conf.d && \
    cat > /etc/php/${PHP_VER}/apache2/conf.d/vicidial.ini <<'EOF'
memory_limit = 512M
max_execution_time = 300
upload_max_filesize = 50M
post_max_size = 50M
display_errors = Off
EOF

# =========================
# 11. ASTERISK DIRS
# =========================
RUN mkdir -p /etc/asterisk && \
    chown -R root:root /etc/asterisk

# =========================
# 12. ENTRYPOINT (DO NOT START SERVICES IN BUILD)
# =========================
RUN cat > /entrypoint.sh <<'EOF'
#!/bin/bash

echo "Starting VICIdial container..."

service mariadb start
service apache2 start
service asterisk start

echo "All services started successfully"

tail -f /var/log/asterisk/full
EOF

RUN chmod +x /entrypoint.sh

# =========================
# 13. PORTS
# =========================
EXPOSE 80 443 5060 10000-20000/udp 3306

# =========================
# 14. HEALTHCHECK
# =========================
HEALTHCHECK CMD curl -f http://localhost || exit 1

WORKDIR /home/vicidial

ENTRYPOINT ["/entrypoint.sh"]