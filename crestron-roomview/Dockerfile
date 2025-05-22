FROM debian:bullseye

ENV FIREFOX_VERSION=52.9.0esr \
    FLASH_VERSION=32.0.0.371

ENV DISPLAY=:99

RUN apt-get update \
 && apt-get install -y \
    wget curl ca-certificates \
    libgtk-3-0 libdbus-glib-1-2 libxt6 libasound2 libnss3 \
    libxrender1 libxcomposite1 libxdamage1 libxrandr2 libgl1-mesa-glx \
    libatk1.0-0 libcups2 libdbus-1-3 \
    x11-xserver-utils \
    bzip2 wget curl ca-certificates \
    libgtk2.0-0 libgdk-pixbuf2.0-0 \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y \
    xvfb x11vnc xauth x11-utils xfonts-base xfonts-100dpi xfonts-75dpi xfonts-cyrillic \
    xserver-xephyr \
    dbus-x11 \
    xdotool \
    procps \
    openbox \
    git \
    libssl-dev libxss1 imagemagick gnome-screenshot scrot nano curl unzip \
 && rm -rf /var/lib/apt/lists/*

# Install Firefox ESR 52
RUN wget -O /tmp/firefox.tar.bz2 "https://ftp.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2" \
    && tar -xjf /tmp/firefox.tar.bz2 -C /opt/ \
    && ln -s /opt/firefox/firefox /usr/bin/firefox

# Firefox Policy-Dateien zur Deaktivierung von Updates
RUN mkdir -p /opt/firefox/defaults/pref && \
    echo 'pref("general.config.filename", "mozilla.cfg");' > /opt/firefox/defaults/pref/local-settings.js && \
    echo 'pref("general.config.obscure_value", 0);' >> /opt/firefox/defaults/pref/local-settings.js && \
    echo '// Disable updates' > /opt/firefox/mozilla.cfg && \
    echo 'lockPref("app.update.enabled", false);' >> /opt/firefox/mozilla.cfg && \
    echo 'lockPref("app.update.auto", false);' >> /opt/firefox/mozilla.cfg && \
    echo 'lockPref("app.update.silent", false);' >> /opt/firefox/mozilla.cfg && \
    echo '' >> /opt/firefox/mozilla.cfg && \
    echo '// Disable default browser check' >> /opt/firefox/mozilla.cfg && \
    echo 'lockPref("browser.shell.checkDefaultBrowser", false);' >> /opt/firefox/mozilla.cfg

# Create plugin folder
RUN mkdir -p /opt/firefox/plugins

# Add Flash Player
COPY install_flash.sh /install_flash.sh
RUN chmod +x /install_flash.sh && /install_flash.sh

ENV MOZ_PLUGIN_PATH=/opt/firefox/plugins

# Add config directory for X-Display and Crestron-RoomView URL
RUN mkdir -p /config

# Add app directory for Python automation
RUN mkdir -p /app
RUN mkdir -p /default

# Set environment variables to perform non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-tk \
    python3-xlib \
    tesseract-ocr \
    gnome-screenshot \
    nano \
    curl \
    unzip \
    xvfb \
    xorg \
    openbox \
    imagemagick \
    xserver-xephyr \
    xauth \
    x11-utils \
    dbus-x11 \
    libssl-dev \
    poppler-utils \
    scrot \
    libxss1 \
    libappindicator3-1 \
 && rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority

# Set workdir and entry
WORKDIR /app

# Copy the requirements.txt into the working directory and install the Python dependencies
COPY requirements.txt /app
RUN python3 -m pip install --upgrade pip && \
    pip3 install -r requirements.txt

# Install the app
RUN mkdir -p /default/images
COPY crestron_roomview_images.sh /tmp/crestron_roomview_images.sh
RUN chmod +x /tmp/crestron_roomview_images.sh
RUN /tmp/crestron_roomview_images.sh
RUN rm /tmp/crestron_roomview_images.sh

COPY crestron_roomview.py /default/crestron_roomview.py
RUN chmod +x /default/crestron_roomview.py

# Entrypoint script für Xvfb, x11vnc und Firefox
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

EXPOSE 5900
CMD ["/opt/start.sh"]
