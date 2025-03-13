# CIP.io-Link

CIP.io-Link is a next-generation, user-friendly evolution of [CIP.io](https://github.com/Argonne-National-Laboratory/CIP.io), designed for **local site deployment** of energy management and EV charging solutions. Developed as part of the **EVs@Scale** initiative, funded by the **U.S. Department of Energy**, CIP.io-Link leverages **Commercial Off-The-Shelf (COTS) hardware** to provide a flexible and scalable platform for managing EV charging infrastructure.

CIPio stands for Common Integration Platform. It is a set of open source applications working together in order to provide a basic way of communicating with each other and external hardware such as meters and services.

## Key Features

### Open Source Software  

CIP.io-Link is an **open-source** project, enabling broad community collaboration and extensibility.

### A Research-Driven, Deployment-Ready Platform

- Designed as a plug-and-play platform for easy smart charge management.
- Functions as a research platform for site and campus-level energy controls.
- Tailored to support experimental setups and foster innovation in VGI and energy management.

### Vision

CIPio Link bridges the gap between research and real-world application, enabling smoother adoption of modern energy management technologies at scale.

### CSMS (Charge Station Management System)  

- Provides a **local** CSMS user interface  
- Includes instructions for integrating **OCPP-compliant** charging stations (OCPP 1.6j)
  - Manage multiple EV charging stations
  - Manage EV drivers and their charging sessions
  - Track charging transactions and energy consumption
  - Employ charge manaaement strategies to optimize energy use and prevent overloads

### Core CIP.io Features  

- **Time-series database** for data storage and analysis  
- **MQTT broker** for efficient site-level messaging  
- **Customizable smart charge management**  

CIP.io-Link brings cutting-edge energy management tools into an **integrated, on-site** platform, enabling **efficient, reliable, and scalable** EV charging solutions.  

## What gets installed?

By default, the CIP.io-Link installer installs the following:

- Docker (if not already isntalled)
- The following containerized apps
  - Node-Red
    - [OCPP nodes](https://www.npmjs.com/package/node-red-contrib-ocpp)
    - [OpenADR nodes](https://www.npmjs.com/package/@anl-ioc/node-red-contrib-oadr-ven)
    - [ModBUS nodes](https://www.npmjs.com/package/node-red-contrib-modbustcp)
    - [Dashboard nodes](https://www.npmjs.com/package/node-red-dashboard)
    - [Dashboard2 nodes](https://www.npmjs.com/package/@flowfuse/node-red-dashboard)
    - [InfluxDb nodes](https://www.npmjs.com/package/node-red-contrib-influxdb)
    - [Redis nodes](https://www.npmjs.com/package/node-red-contrib-redis)
    - [Flow-Manager](https://www.npmjs.com/package/node-red-contrib-flow-manager)
  - InfluxDb (v2)
  - ValKey (Redis fork)
  - Grafana
  - Mosquitto MQTT broker
  - Portainer container manager
  - git, crul, and jq (if not already installed)

### Application and Docker Hub references

Web Reference | Docker Hub Reference
------------ | --------------------
[Grafana](https://grafana.com) | [Grafana](https://hub.docker.com/r/grafana/grafana)
[Node-Red](https://nodered.org) | [Node-Red](https://hub.docker.com/r/nodered/node-red)
[InfluxDb](https://www.influxdata.com) | [InfluxDb](https://hub.docker.com/_/influxdb)
[ValKey](https://www.valkey.io) | [ValKey](https://hub.docker.com/r/valkey/valkey)
[Mosquitto](https://mosquitto.org/) | [Mosquitto](https://hub.docker.com/_/eclipse-mosquitto)
[Portainer](https://www.portainer.io) | [Portainer](https://hub.docker.com/r/portainer/portainer-ce)

## Requirements

### Hardware

CIP.io-Link is designed to run on a **local server** or **edge device**. Although it may be possible to deploy
CIP.io-Link on a single board computer such as a Raspberry-Pi5, all testing has been done on Intel slim platform
devices such as Dell Optiplex and Lenovo/Intel NUC devices. The following hardware specifications are recommended:

- Minimum 8GB RAM
- Minimum 128GB SSD/HDD
- i5 or equivalent processor
- Hardwired ethernet or Wi-Fi connection
- OS installtaion:
  - Mouse and keyboard
  - USB port for initial installation of OS if not already installed

## Operating System

- Linux (Ubuntu 24.04 LTS recommended, desktop works well)

Currently, this installation has only been tested on Ubuntu 24.04 LTS. We hope to add other variations of Linux in the future. The installation script is designed to run on a fresh install of Ubuntu 24.04 LTS.

Once the OS/Linux is installed it requires that you have root access (sudo) in order to install Docker and other parts.

CIP.io-Link is designed to run headless (no monitor, keyboard, or mouse) and can be accessed via a web browser on another device on the same network. You may wish to enable SSH access to the device in order to manage it remotely.

## :scroll: The Install script

*[ :point_right: You may wish to read this entire README file and [Wiki](https://github.com/Argonne-National-Laboratory/CIP.io-Link/wiki) prior to running the install script]*

Open up a command line terminal and change directories to the location you wish to install CIP.io-Link. You must have permissions in this folder to create files and folders.
Upon execution of the installation script, and new folder will be created name CIP.io-Link. This is where everything is installed and run from.

You do not need to initially run the script as root (sudu). The script will prompt you for your root password when it runs.

To install, click the "[copy]" button in the following code sample, the paste that into your terminal to execute.

```bash

wget -q https://raw.githubusercontent.com/Argonne-National-Laboratory/CIP.io-Link/main/scripts/install.sh -O /tmp/install.sh && \
    chmod +x /tmp/install.sh && \
    /tmp/install.sh
```

The above lines of code will do the following:

- Download the initial install script to the /tmp folder and run it
- Verify that git, curl, jq, and Docker are installed
- Download the remainder of the files needed from this repository
  - There is no need to manually clone this repository prior to installation. The script will do that for you.
- Prompt you for information needed to run CIP.io-Link
  - Create a default user and password used by the various components/containers
  - Prompt you for the port number you wish to associate with the CSMS URL
  - Prompt you for a route (or path) to associate with the CSMS URL
  - It will create a random password used by ValKey (Redis). Taking the default is recommended.
- Setup and configure various docker containers and run them

When finished, a URL for accessing the CIP.io-Link dashboard will be displayed. You can enter that into a browser to access the dashboard.

### Docker

You can find out more about Docker [HERE](https://www.docker.com).

### Adding your linux account to the docker group

Once installed, your Linux user will also be added to the "docker" user group on your system. This will keep you from having to sudu your account in order to do to certain docker activities (docker pull/up/down/ps). You may have to exit and restart your terminal in order for this to take affect the first time.

### Future Enhancements (OCPP 2.x Version)  

- **ISO-15118 Charge Scheduling Application**  
- Acts as a **local OCPP node**  
