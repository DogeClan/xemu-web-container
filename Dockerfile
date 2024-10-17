# Use a base image with a minimal installation of Ubuntu
FROM ubuntu:22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV NOVNC_VERSION=1.3.0
ENV SDL_AUDIODRIVER=dummy

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
    pulseaudio \
    && rm -rf /var/lib/apt/lists/*

# Create a PulseAudio configuration file
RUN echo "daemonize = yes" > /etc/pulse/daemon.conf && \
    echo "system-instance = yes" >> /etc/pulse/daemon.conf && \
    echo "enable-shm = yes" >> /etc/pulse/daemon.conf && \
    echo "autospawn = no" >> /etc/pulse/client.conf && \
    echo "daemon-binary = /bin/true" >> /etc/pulse/client.conf

# Create PulseAudio runtime directory
RUN mkdir -p /tmp/pulse && \
    chmod 777 /tmp/pulse

# Clone and build xemu emulator
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu && \
    cd /xemu && \
    ./build.sh --enable-vnc

# Clone noVNC and install websockify via pip
RUN git clone https://github.com/novnc/noVNC.git /noVNC && \
    cd /noVNC && \
    git checkout v$NOVNC_VERSION && \
    pip3 install --no-cache-dir websockify websocket-client && \
    pip3 cache purge

# Expose the WebSocket port for Websockify and noVNC
EXPOSE 8080

# Set the working directory
WORKDIR /xemu

# Start PulseAudio and the main application
CMD bash -c "pulseaudio --start --system && \
    xvfb-run --server-args='-screen 0 1024x768x24' ./dist/xemu -display vnc=:0 -audiodev alsa,id=audiodev0,driver=alsa,model=hda & \
    sleep 3 && \
    websockify 8080 localhost:5900 --web /noVNC"
