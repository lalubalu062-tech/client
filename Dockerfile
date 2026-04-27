# Base image
FROM ubuntu:22.04

# Disable interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install XFCE desktop, XRDP, and required tools
RUN apt-get update && \
    apt-get install -y xfce4 xfce4-goodies xrdp sudo dbus-x11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user for RDP login (Username: jeet, Password: password123)
RUN useradd -m -s /bin/bash jeet && \
    echo "jeet:password123" | chpasswd && \
    usermod -aG sudo jeet

# Configure XRDP to use XFCE
RUN echo "xfce4-session" > /home/jeet/.xsession && \
    chown jeet:jeet /home/jeet/.xsession

# Expose RDP port
EXPOSE 3389

# Create a startup script to run services in the foreground
RUN echo '#!/bin/sh\nservice dbus start\nservice xrdp start\ntail -f /var/log/xrdp.log' > /start.sh && \
    chmod +x /start.sh

# Start the script when container runs
CMD ["/start.sh"]
