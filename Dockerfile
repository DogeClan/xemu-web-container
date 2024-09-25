# Use an official Debian image as a base
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99

# Install required packages, including Xvfb and x11vnc for headless execution
RUN apt-get update && apt-get install -y \
    git \
    libgtk-3-dev \
    build-essential \
    libsdl2-dev \
    libepoxy-dev \
    libpixman-1-dev \
    libssl-dev \
    libsamplerate0-dev \
    libpcap-dev \
    ninja-build \
    python3-yaml \
    libslirp-dev \
    novnc \
    websockify \
    xvfb \
    x11vnc \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the xemu repository from GitHub
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu

# Set the working directory
WORKDIR /xemu

# Create persistent volumes for xemu data and config
VOLUME ["/root/.local/share/xemu", "/xemu"]

# Run the build script
RUN ./build.sh

# Set permissions on xemu folder
RUN chown -R root:root /root/.local/share/xemu /xemu

# Install Tini as an init system to handle process management
RUN apt-get update && apt-get install -y tini && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose Render's web app port (10000)
EXPOSE 10000

# Use Tini as the entry point
ENTRYPOINT ["/usr/bin/tini", "--"]

# Set the entry point to run Xvfb, x11vnc, xemu, and websockify in headless mode
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x16 & x11vnc -display :99 -nopw -forever -rfbport 5900 & DISPLAY=:99 ./dist/xemu & websockify --web=/usr/share/novnc 10000 localhost:5900 && wait"]
