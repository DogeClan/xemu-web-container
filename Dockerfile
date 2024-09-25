# Use an official Debian image as a base
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages, including Xvfb for headless execution
RUN apt-get update && apt-get install -y \
    git \
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
    xvfb \  # Install Xvfb for running GUI apps in headless mode
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the xemu repository from GitHub
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu

# Set the working directory
WORKDIR /xemu

# Create persistent volumes for xemu data and config
VOLUME ["/root/.local/share/xemu"]
VOLUME ["/xemu"]

# Run the build script
RUN ./build.sh

# Set the entry point to run Xvfb and xemu in headless mode
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x16 & DISPLAY=:99 ./dist/xemu -vnc :0 & websockify --web=/usr/share/novnc 6080 localhost:5900"]
