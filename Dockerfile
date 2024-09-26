# Base image
FROM debian:latest

# Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools and libraries
RUN apt-get update && apt-get install -y \
    git \
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
    libx11-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    x11-xserver-utils \
    xorg \
    xvfb \
    tigervnc-standalone-server \
    websockify \
    python3-pip \
    alsa-utils \
    unzip \
    curl \
    sudo \
    && apt-get clean

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
    cd /opt/noVNC && \
    git checkout v1.2.0 && \
    ln -s vnc_lite.html index.html

# Install WebSockify
RUN git clone https://github.com/novnc/websockify /opt/websockify && \
    cd /opt/websockify && \
    python3 setup.py install

# Clone and build xemu
RUN git clone https://github.com/mborgerson/xemu.git /opt/xemu && \
    cd /opt/xemu && \
    ./build.sh

# Setup a virtual framebuffer for headless operation
RUN apt-get install -y xvfb && \
    mkdir -p /var/run/xvfb

# Create a startup script
RUN echo '#!/bin/bash\n\
Xvfb :99 -screen 0 1280x800x24 &\n\
export DISPLAY=:99\n\
/opt/websockify/run 5900 localhost:5901 &\n\
/opt/noVNC/utils/launch.sh --vnc localhost:5900 &\n\
/opt/xemu/dist/xemu' > /usr/local/bin/start-xemu && \
    chmod +x /usr/local/bin/start-xemu

# Expose noVNC port
EXPOSE 6080

# Start xemu through noVNC and WebSockify
CMD ["/usr/local/bin/start-xemu"]
