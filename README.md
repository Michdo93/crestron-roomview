# crestron-roomview

A Docker container for the use of Crestron RoomView. This program is remotely controlled with Firefox 52 and Flash Player 32 in a virtual display by a Python script.

Crestron RoomView is an application for controlling projectors.

![Crestron RoomView](https://raw.githubusercontent.com/Michdo93/openHAB-Crestron-Room-View-Control/main/crestron_room_view.JPG)

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

## 🧠 Available Commands

You can control the projector or display device by executing one of the following Python functions inside the container:

```bash
docker exec -it crestron-roomview /usr/bin/python3 /app/crestron_roomview.py <command>
```

| Command                   | Description                                                            |
| ------------------------- | ---------------------------------------------------------------------- |
| `togglePower`             | Toggles the projector power ON or OFF, depending on the current state. |
| `powerOn`                 | Turns the projector ON.                                                |
| `powerOff`                | Turns the projector OFF.                                               |
| `reduceVolume`            | Decreases the audio volume.                                            |
| `increaseVolume`          | Increases the audio volume.                                            |
| `muteVolume`              | Toggles mute ON or OFF.                                                |
| `changeSourceToComputer1` | Switches the input source to "Computer 1".                             |
| `changeSourceToComputer2` | Switches the input source to "Computer 2".                             |
| `changeSourceToHDMI1`     | Switches the input source to "HDMI 1".                                 |
| `changeSourceToHDMI2`     | Switches the input source to "HDMI 2".                                 |
| `changeSourceToVideo`     | Switches the input source to "Video".                                  |
| `changeSourceToSVideo`    | Switches the input source to "S-Video".                                |
| `source`                  | Opens the source selection menu.                                       |
| `auto`                    | Triggers automatic image adjustment.                                   |
| `blank`                   | Blanks (hides) the current display output.                             |
| `enter`                   | Sends an Enter key action (usually for menu confirmation).             |
| `freeze`                  | Freezes the current screen image.                                      |
| `openMenu`                | Opens the projector menu.                                              |
| `menuLeft`                | Navigates the menu to the left.                                        |
| `menuRight`               | Navigates the menu to the right.                                       |
| `menuUp`                  | Navigates the menu upwards.                                            |
| `menuDown`                | Navigates the menu downwards.                                          |
| `increaseBrightness`      | Increases the screen brightness.                                       |
| `decreaseBrightness`      | Decreases the screen brightness.                                       |
| `increaseContrast`        | Increases the contrast of the display.                                 |
| `decreaseContrast`        | Decreases the contrast of the display.                                 |
| `increaseSharpness`       | Increases the image sharpness.                                         |
| `decreaseSharpness`       | Decreases the image sharpness.                                         |

> 💡 All functions simulate button interactions via image recognition and browser control.

## 🛠️ Optional: Manual Build

If you want to build the container locally (without cache), use:

```bash
docker compose build --no-cache
```

---

## Example usage: openHAB integration

Of course, you can now also integrate the beamer/projector into your smart home system. I will now explain this using the example of openHAB.

### exec.whitelist

In the `exec.whitelist` file, you enter commands that may be executed from your system by the `Exec Binding` or by `Exec Actions` in Rules. A special permission means a whitelist procedure. Hence the name of the file. It is usually located under `/etc/openhab/misc/exec.whitelist`.

If the Docker container is running on the same system, you can enter the following command, for example:

```
/usr/bin/docker exec -it crestron-roomview /usr/bin/python3 /app/crestron_roomview.py %2$s
```

If the Docker container is running on a different system, you can enter the following command, for example:

```
/usr/bin/sshpass -p <password> /usr/bin/ssh -t -o StrictHostKeyChecking=no <username>@<ip> '/usr/bin/docker exec -it crestron-roomview /usr/bin/python3 /app/crestron_roomview.py %2$s'
```

Please replace `<username>`, `<password>` and `<ip>` with the username, password and ip from your Docker system (system where you have Docker installed and running). Für SSH empfehle ich auch `sshpass` zu installieren und zu verwenden. Stelle allerdings vorher sicher, dass der openHAB-User einen `Fingerprint` für SSH besitzt (`ssh -u openhab sshpass -p <password> <username>@<ip>`).

The parameter `%2$s` means that any parameter can be inserted at this point. This is very practical because we control the program remotely via various parameters in the command line, e.g. `togglePower`, `powerOn`, `powerOff`

### Items

We use a separate `switch` item for each command to be controlled at the end. Items are usually stored and created in `/etc/openhab/items`. You can create this items as example with `sudo nano /etc/openhab/items/crestron.items`:

```
Group Crestron_RoomView_Control "Crestron RoomView Control" <screen>

Switch Crestron_RoomView_Control_TogglePower "On/off projector" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_VolumeDown "Decrease volume" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_VolumeUp "Increase volume" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_Mute_Volume "Mute volume" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_SrcToComputer1 "Computer1/YPbPr1" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_SrcToComputer2 "Computer2/YPbPr2" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_SrcToHDMI1 "HDMI1" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_SrcToHDMI2 "HDMI2" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_SrcToVideo "Video" (Crestron_RoomView_Control)
// The following functions may work, but it will be more difficult to operate them correctly.
Switch Crestron_RoomView_Control_Source "Source" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_Auto "Auto adjust" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_Blank "Blank screen" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_Enter "Enter" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_Freeze "Freeze image" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_OpenMenu "Open menu" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_MenuLeft "Menu left" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_MenuRight "Menu right" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_MenuUp "Menu up" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_MenuDown "Menu down" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_IncreaseBrightness "Increase brightness" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_DecreaseBrightness "Decrease brightness" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_IncreaseContrast "Increase contrast" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_DecreaseContrast "Decrease contrast" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_IncreaseSharpness "Increase sharpness" (Crestron_RoomView_Control)
Switch Crestron_RoomView_Control_DecreaseSharpness "Decrease sharpness" (Crestron_RoomView_Control)
```

### Sitemaps

A sitemap can be created so that items can also be operated. A sitemap is usually located in `/etc/openhab/sitemaps`. A `sitemap` could look like this (e.g. `sudo nano /etc/openhab/sitemaps/crestro.sitemaps`):

```
sitemap crestron label="Crestron RoomView"
{
    Text label="Crestron RoomView Control" icon="screen" {
        
        // Power & Audio
        Switch item=Crestron_RoomView_Control_TogglePower label="On/off projector" mappings=[ON="Power"]
        Switch item=Crestron_RoomView_Control_VolumeDown label="Decrease volume" mappings=[ON="Vol -"]
        Switch item=Crestron_RoomView_Control_VolumeUp label="Increase volume" mappings=[ON="Vol +"]
        Switch item=Crestron_RoomView_Control_Mute_Volume label="Mute volume" mappings=[ON="Mute"]

        // Source Selection
        Switch item=Crestron_RoomView_Control_SrcToComputer1 label="Computer1/YPbPr1" mappings=[ON="Computer1"]
        Switch item=Crestron_RoomView_Control_SrcToComputer2 label="Computer2/YPbPr2" mappings=[ON="Computer2"]
        Switch item=Crestron_RoomView_Control_SrcToHDMI1 label="HDMI1" mappings=[ON="HDMI1"]
        Switch item=Crestron_RoomView_Control_SrcToHDMI2 label="HDMI2" mappings=[ON="HDMI2"]
        Switch item=Crestron_RoomView_Control_SrcToVideo label="Video" mappings=[ON="Video"]
        Switch item=Crestron_RoomView_Control_Source label="Source" mappings=[ON="Source"]

        // Basic Controls
        Switch item=Crestron_RoomView_Control_Auto label="Auto Adjust" mappings=[ON="Auto"]
        Switch item=Crestron_RoomView_Control_Blank label="Blank Screen" mappings=[ON="Blank"]
        Switch item=Crestron_RoomView_Control_Freeze label="Freeze Image" mappings=[ON="Freeze"]
        Switch item=Crestron_RoomView_Control_Enter label="Enter" mappings=[ON="Enter"]
        Switch item=Crestron_RoomView_Control_OpenMenu label="Open Menu" mappings=[ON="Menu"]

        // Menu Navigation
        Switch item=Crestron_RoomView_Control_MenuUp label="Menu Up" mappings=[ON="↑"]
        Switch item=Crestron_RoomView_Control_MenuDown label="Menu Down" mappings=[ON="↓"]
        Switch item=Crestron_RoomView_Control_MenuLeft label="Menu Left" mappings=[ON="←"]
        Switch item=Crestron_RoomView_Control_MenuRight label="Menu Right" mappings=[ON="→"]

        // Image Settings
        Switch item=Crestron_RoomView_Control_IncreaseBrightness label="Brightness +" mappings=[ON="+"]
        Switch item=Crestron_RoomView_Control_DecreaseBrightness label="Brightness -" mappings=[ON="-"]
        Switch item=Crestron_RoomView_Control_IncreaseContrast label="Contrast +" mappings=[ON="+"]
        Switch item=Crestron_RoomView_Control_DecreaseContrast label="Contrast -" mappings=[ON="-"]
        Switch item=Crestron_RoomView_Control_IncreaseSharpness label="Sharpness +" mappings=[ON="+"]
        Switch item=Crestron_RoomView_Control_DecreaseSharpness label="Sharpness -" mappings=[ON="-"]
    }
}
```

### Rules

We then use rules to access our program in the Docker container to remotely control the beamer/projector. Depending on where Docker is running, this can be done with or without SSH. Rules are usually stored in `/etc/openhab/rules`. However, if you use `Scripted Automation`, e.g. when using Jython rules, then there are other paths. In the following I will give both `DSL Rules` and `Jython Rules` as an example both with SSH and without.

---

## 📝 License

MIT License – see [LICENSE](LICENSE).
