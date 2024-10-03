# Use the official Debian Bullseye base image
FROM debian:bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV GUACAMOLE_VERSION=1.4.0
ENV XEMU_VERSION=latest

# Install necessary tools for adding repository and fetching packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg2 \
    lsb-release \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Attempt to add the libjpeg-turbo repository and install the package
RUN wget -q -O /etc/apt/trusted.gpg.d/libjpeg-turbo.gpg https://packagecloud.io/dcommander/libjpeg-turbo/gpgkey || \
    echo "Failed to fetch GPG key, falling back to Debian repository" && \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" > /etc/apt/sources.list.d/debian.list

# Update apt and install libjpeg-turbo from Debian repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends libjpeg-turbo && \
    rm -rf /var/lib/apt/lists/*

# Install other required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    websockify \
    build-essential \
    libsdl2-dev \
    libepoxy-dev \
    libpixman-1-dev \
    libgtk-3-dev \
    libssl-dev \
    libsamplerate0-dev \
    libpcap-dev \
    ninja-build \
    python3-yaml \
    libslirp-dev \
    python3-dbus \
    python3-avahi \
    python3-pyinotify \
    python3-uinput \
    dbus \
    x11vnc \
    xvfb \
    tomcat9 \
    tomcat9-admin \
    libtomcat9-java \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install Guacamole Server
RUN curl -L https://apache.org/dyn/closer.cgi/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-server-${GUACAMOLE_VERSION}.tar.gz -o guacamole-server.tar.gz && \
    tar -xzf guacamole-server.tar.gz && \
    cd guacamole-server-${GUACAMOLE_VERSION} && \
    ./configure --with-init-dir=/etc/init.d && \
    make && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf guacamole-server-${GUACAMOLE_VERSION} guacamole-server.tar.gz

# Download and install Guacamole Client
RUN curl -L https://apache.org/dyn/closer.cgi/guacamole/${GUACAMOLE_VERSION}/binary/guacamole.war -o /var/lib/tomcat9/webapps/guacamole.war

# Configure Guacamole
RUN mkdir -p /etc/guacamole && \
    echo "guacamole.home: /etc/guacamole" > /etc/guacamole/guacamole.properties && \
    echo "user-mapping: /etc/guacamole/user-mapping.xml" >> /etc/guacamole/guacamole.properties && \
    cp /etc/guacamole/guacamole.properties /usr/share/tomcat9/.guacamole/

# Create an example user mapping file
RUN echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<user-mapping>\n\
    <authorize username="user" password="password">\n\
        <connection>\n\
            <name>Xemu Emulator</name>\n\
            <protocol>vnc</protocol>\n\
            <param name="hostname">localhost</param>\n\
            <param name="port">5901</param>\n\
            <param name="width">1280</param>\n\
            <param name="height">720</param>\n\
        </connection>\n\
    </authorize>\n\
</user-mapping>' > /etc/guacamole/user-mapping.xml

# Clone xemu repository and build it
RUN git clone --depth 1 https://github.com/xemu-project/xemu.git /xemu && \
    cd /xemu && \
    ./build.sh

# Create a placeholder CD-ROM image (for example)
RUN dd if=/dev/zero of=/xemu/image.iso bs=1M count=1 && \
    echo "Placeholder CD-ROM image created."

# Create start script for Xemu and VNC server
RUN echo '#!/bin/bash\n\n\
# Start Xvfb in the background\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2  # Give Xvfb time to start\n\
\n\
# Set the DISPLAY variable for Xemu\n\
export DISPLAY=:1\n\
\n\
# Start x11vnc to export the Xvfb display to VNC\n\
x11vnc -display :1 -nopw -forever -ncache 10 -noxdamage -listen localhost -rfbport 5901 &\n\
\n\
# Start Xemu\n\
cd /xemu && ./dist/xemu -machine xbox,kernel-irqchip=off,avpack=hdtv \\\n\
    -device smbus-storage,file=/root/.local/share/xemu/xemu/eeprom.bin \\\n\
    -m 64 -drive index=1,media=cdrom,file=/xemu/image.iso -display vnc:null\n\
' > /start.sh && chmod +x /start.sh

# Expose necessary ports
EXPOSE 8080 5901

# Start services
CMD ["sh", "-c", "/usr/share/tomcat9/bin/catalina.sh run & /start.sh"]
