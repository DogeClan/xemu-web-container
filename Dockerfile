# Use a base image with a minimal installation of Ubuntu
FROM ubuntu:22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV NOVNC_VERSION=1.3.0

# Install required packages and dependencies in a single RUN statement to reduce layers
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    libvncserver-dev \
    libslirp-dev \
    xvfb \
    net-tools \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Clone and build xemu emulator without audio support
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu && \
    cd /xemu && \
    ./build.sh --enable-vnc --disable-audio

# Clone noVNC and install websockify via pip
RUN git clone https://github.com/novnc/noVNC.git /noVNC && \
    cd /noVNC && \
    git checkout v$NOVNC_VERSION && \
    pip3 install --no-cache-dir websockify websocket-client

# Expose the WebSocket port for Websockify and noVNC
EXPOSE 8080

# Set entrypoint to start xemu and bind to the dynamically assigned port.
CMD ["bash", "-c", "xvfb-run --server-args='-screen 0 1024x768x24' /xemu/dist/xemu -display vnc=:0 -audiodev none & sleep 5 && websockify 8080 localhost:5900 --web /noVNC"]
