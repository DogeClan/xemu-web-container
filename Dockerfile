# Use the official Debian base image
FROM debian:bullseye

# Set environment variables to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install required dependencies
RUN apt-get update && apt-get install -y \
    xpra \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the xemu repository
RUN git clone --recurse-submodules https://github.com/xemu-project/xemu.git /xemu

# Set working directory to xemu
WORKDIR /xemu

# Build xemu
RUN ./build.sh

# Expose Xpra web port
EXPOSE 8080

# Start xpra server to run xemu on the web
# Make sure to replace "./path/to/xemu/executable" with the actual path of the built executable
CMD ["xpra", "start", "--web", "on", "--bind-tcp=0.0.0.0:8080", "--", "./dist/xemu"]
