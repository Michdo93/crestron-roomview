# crestron-roomview

A Docker container for the use of Crestron RoomView. This program is remotely controlled with Firefox 52 and Flash Player 32 in a virtual display by a Python script.

## 📦 Docker Image

The image is available on Docker Hub:

```bash
docker pull michdo93/crestron-roomview
````

## 🐳 Docker Compose Example

```yaml
version: '3.8'

volumes:
  x11socket:

services:
  crestron-roomview:
    build: ./crestron-roomview
    container_name: crestron-roomview
    volumes:
      - x11socket:/tmp/.X11-unix
      - /opt/docker/containers/crestron-roomview/config/url.txt:/config/url.txt:ro
      - /opt/docker/containers/crestron-roomview/config/resolution.txt:/config/resolution.txt:ro
      - /opt/docker/containers/crestron-roomview/config/display.txt:/config/display.txt:ro
      - /opt/docker/containers/crestron-roomview/app:/app
    environment:
      DISPLAY: ':99'
    restart: unless-stopped
    network_mode: "host"
```

## 📁 Required Files and Directories

Before starting the container, make sure the following files and folders exist on your host:

```bash
/opt/docker/containers/crestron-roomview/
├── config/
│   ├── url.txt          # e.g. http://192.168.0.59/
│   ├── resolution.txt   # e.g. 1920x1200x24
│   └── display.txt      # e.g. :99
└── app/                 # optional: custom scripts like crestron_roomview.py
```

> **Note:** The value in `display.txt` **must match** the `DISPLAY` environment variable defined in the Compose file (recommended: `:99`). If you choose a different display number, make sure Xvfb is started accordingly and the Python script is updated as well.

Make sure you create it with:

```
mkdir -p /opt/docker/containers/crestron-roomview/app
mkdir -p /opt/docker/containers/crestron-roomview/config
```

## 🖥️ Display Resolution

The default resolution is:

```
1920x1200x24
```

You can adjust this by editing the `resolution.txt` file. At first you have to create it with:

```
echo "1920x1200x24" >> /opt/docker/containers/crestron-roomview/config/resolution.txt
```

## 🖥️ Display

For the `DISPLAY` we use `:99`. If you want to use something else, you have to adjust the `docker-compose.yml` file, as well as the Python script (you can find it in the volumes), and restart `Xfvb` in the Docker container manually or by using the `display.txt` file.

At first you have to create it with:

```
echo ":99" >> /opt/docker/containers/crestron-roomview/config/display.txt
```

> The `DISPLAY` variable is set via the `docker-compose` file, the `display.txt` file only starts services such as `Xvfb` with the corresponding variable. The Python script must always be adapted manually.

## 🌐 URL Configuration

The `url.txt` file must contain the URL to your Crestron RoomView web interface, e.g.:

```text
http://192.168.0.59/
```

Modify this according to where your RoomView system is hosted.
```
echo "http://192.168.0.59/" >> /opt/docker/containers/crestron-roomview/config/url.txt
```

## 🔌 Toggle Projector/Beamer Power

To toggle the projector or display device on or off, run the following command:

```bash
docker exec -it crestron-roomview /usr/bin/python3 /app/crestron_roomview.py togglePower
```

> Make sure the `DISPLAY` environment inside the container is correctly set to match what's in `display.txt` (typically `:99`).

## 🛠️ Optional: Manual Build

If you want to build the container locally (without cache), use:

```bash
docker compose build --no-cache
```

---

## 📝 License

MIT License – see [LICENSE](LICENSE).
