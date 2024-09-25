# Use an official Ubuntu image as a base
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for building xemu
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
    novnc \
    websockify \
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

# Set the entry point (optional, you can modify this as needed)
CMD ["sh", "-c", "./dist/xemu -vnc :0 & websockify --web=/usr/share/novnc 6080 localhost:5900"]
