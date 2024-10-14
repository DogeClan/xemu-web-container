# Use a base image with a minimal installation of Ubuntu
FROM ubuntu:22.04

# Set environment variables for non-interactive installation and noVNC/Websockify
ENV DEBIAN_FRONTEND=noninteractive
ENV NOVNC_VERSION=1.3.0
ENV WEBSOCKIFY_VERSION=0.10.0
ENV XEMU_VERSION=latest

# Install required packages and dependencies
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
    python3 \
    python3-pip \
    python3-yaml \
    libslirp-dev \
    xvfb \
    x11vnc \
    net-tools \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Clone and build xemu emulator
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu && \
    cd /xemu && \
    ./build.sh

# Clone noVNC and Websockify
RUN git clone https://github.com/novnc/noVNC.git /noVNC && \
    git clone https://github.com/novnc/websockify.git /websockify && \
    cd /websockify && \
    pip3 install websocket-client

# Expose the WebSocket port for Websockify and noVNC
EXPOSE 6080
EXPOSE 5901

# Start the xemu VNC server and Websockify
CMD ["sh", "-c", "xvfb-run --server-args='-screen 0 1024x768x24' ./xemu/dist/xemu -display gtk -no-audio -vga std -m 256M -vnc :1 & \
                  sleep 2 && \
                  python3 /websockify/websockify.py --web=/noVNC 6080 localhost:5901"]
