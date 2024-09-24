# Use an official Ubuntu image as a base
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for building xemu
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    cmake \
    ninja-build \
    libsdl2-dev \
    libglew-dev \
    libgtk-3-dev \
    libglib2.0-dev \
    libgtkmm-3.0-dev \
    libopenal-dev \
    libepoxy-dev \
    libasound2-dev \
    libpulse-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libx11-dev \
    libxext-dev \
    libxkbcommon-dev \
    libwayland-dev \
    libxcomposite-dev \
    libxrender-dev \
    libxdamage-dev \
    libxcb1-dev \
    libxcb-glx0-dev \
    libxshmfence-dev \
    libdrm-dev \
    libgbm-dev \
    libudev-dev \
    libpci-dev \
    libnettle-dev \
    libgl-dev \
    mesa-utils \
    libegl1-mesa-dev \
    libglu1-mesa-dev \
    gcc \
    g++ \
    pkg-config \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libxml2-dev \
    libx11-xcb-dev \
    libxext-dev \
    libwayland-dev \
    libcurl4-openssl-dev \
    liblzma-dev \
    libzstd-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    libudev-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libavutil-dev \
    libgtk2.0-dev \
    clang \
    python3 \
    python3-pip \
    doxygen \
    novnc \
    websockify \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the xemu repository from GitHub
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu

# Set the working directory
WORKDIR /xemu

# Run the build script
RUN ./build.sh

# Set the entry point (optional, you can modify this as needed)
CMD ["sh", "-c", "./dist/xemu -vnc :0 & websockify --web=/usr/share/novnc 6080 localhost:5900"]
