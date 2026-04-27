# Base image
FROM ubuntu:22.04

# Disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Desktop, XRDP, dbus aur Terminal
RUN apt-get update && \
    apt-get install -y xfce4 xfce4-goodies xfce4-terminal xrdp sudo dbus-x11 wget curl gnupg && \
    apt-get clean

# FIX: XRDP SSL certificate permission
RUN adduser xrdp ssl-cert

# 2. Install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# 3. Install Wine (For Windows .exe apps)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wine64 wine32 && \
    apt-get clean

# Create user (Username: jeet, Password: password123)
RUN useradd -m -s /bin/bash jeet && \
    echo "jeet:password123" | chpasswd && \
    usermod -aG sudo jeet

# Force XRDP to use XFCE4
RUN sed -i 's/^test -x/#test -x/g' /etc/xrdp/startwm.sh && \
    sed -i 's/^exec \/bin\/sh/#exec \/bin\/sh/g' /etc/xrdp/startwm.sh && \
    echo "startxfce4" >> /etc/xrdp/startwm.sh

# Expose Port
EXPOSE 3389

# Start script
RUN echo '#!/bin/sh\nservice dbus start\nservice xrdp start\ntail -f /var/log/xrdp.log' > /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]
