# Use the official Debian Bullseye base image
FROM debian:bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
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
    libgtk-3-0 \
    x11vnc \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Clone noVNC and websockify
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc && \
    cd /usr/share/novnc && \
    git submodule update --init --recursive 

# Clone xemu repository
RUN git clone --depth 1 https://github.com/xemu-project/xemu.git /xemu && \
    cd /xemu && \
    ./build.sh

# Create a placeholder CD-ROM image
RUN dd if=/dev/zero of=/xemu/image.iso bs=1M count=1 && \
    echo "Placeholder CD-ROM image created."

# Create start script
RUN echo '#!/bin/bash\n\n\
# Start Xvfb in the background\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2  # Give Xvfb time to start\n\
\n\
# Set the DISPLAY variable for xemu\n\
export DISPLAY=:1\n\
\n\
# Start x11vnc to export the Xvfb display to VNC\n\
x11vnc -display :1 -nopw -forever -many -listen localhost -rfbport 54321 -ncache 10 &\n\
\n\
# Create a path to the CD-ROM image\n\
CD_IMAGE="/xemu/image.iso"  # Ensure this corresponds to your valid ISO\n\
\n\
# Start xemu (make sure to configure here according to your requirements)\n\
cd /xemu && ./dist/xemu -machine xbox,kernel-irqchip=off,avpack=hdtv \\\n\
    -device smbus-storage,file=/root/.local/share/xemu/xemu/eeprom.bin \\\n\
    -m 64 -drive index=1,media=cdrom,file=${CD_IMAGE} -display vnc,null\n\
\n\
# Start noVNC with a longer timeout\n\
websockify --web=/usr/share/novnc 6080 localhost:54321 --timeout=3600 &\n\
\n\
# Keep the script running\n\
wait -n' > /start.sh && chmod +x /start.sh

# Set the working directory
WORKDIR /usr/share/novnc

# Expose the noVNC port
EXPOSE 6080

# Run the application
CMD ["/start.sh"]
