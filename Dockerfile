# Use the latest Debian base image
FROM debian:latest

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install required packages
RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    clang \
    g++ \
    gcc \
    cmake \
    libgtk-3-dev \
    libglib2.0-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libx11-dev \
    libxext-dev \
    libxi-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libcap-dev \
    libz-dev \
    libpixman-1-dev \
    libfreetype6-dev \
    libfontconfig1-dev \
    libpulse-dev \
    libasound2-dev \
    libudev-dev \
    libxmu-dev \
    libxi-dev \
    novnc \
    ninja-build \
    websockify \
    && apt-get clean

# Install Node.js and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Clone the xemu repository
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu

# Build xemu
WORKDIR /xemu

RUN ./build.sh

# Clean up unnecessary files
RUN rm -rf /xemu

# Expose the VNC port and the web server port
EXPOSE 5900 6080

# Start xemu with web VNC using noVNC
CMD ["sh", "-c", "./dist/xemu -vnc :0 & websockify --web=/usr/share/novnc 6080 localhost:5900"]
