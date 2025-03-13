# This is a CIPio Link install test

Nothing to see here. I will be removed in the next 48hrs anyway.

Copy and paste the following command to install this package using CIPio:

```bash

wget -q https://raw.githubusercontent.com/Argonne-National-Laboratory/CIP.io-Link/main/scripts/install.sh -O /tmp/install.sh && \
    chmod +x /tmp/install.sh && \
    /tmp/install.sh

```
# CIPio

### Common Integration Platform io

CIPio stands for Common Integratio Platform. It is a set of open source applications working together in order to provide a basic way of comminucating with common... [finish me]

## What gets installed?

By default, the CIPio installer installs the following:

- Docker (if not already isntalled)
- Docker Compose (if not already installed)
- The following containerized apps
  - Node-Red
    - [OCPP nodes](https://www.npmjs.com/package/node-red-contrib-ocpp)
    - [OpenADR nodes](https://www.npmjs.com/package/@anl-ioc/node-red-contrib-oadr-ven)
    - [ModBUS nodes](https://www.npmjs.com/package/node-red-contrib-modbustcp)
    - [BACNet nodes](https://www.npmjs.com/package/node-red-contrib-bacnet)
    - [Dashboard nodes](https://www.npmjs.com/package/node-red-dashboard)
    - [InfluxDb nodes](https://www.npmjs.com/package/node-red-contrib-influxdb)
    - [MongoDb nodes](https://www.npmjs.com/package/node-red-node-mongodb)
  - InfluxDb (v1.8 and/or v2.0)
  - MongoDb
  - Mongo Express
  - Grafana
  - Mosquitto MQTT broker
  - Portainer container manager
  - Watchtower container updater

### Application and Docker Hub references

Web Reference | Docker Hub Reference
------------ | --------------------
[Grafana](https://grafana.com) | [Grafana](https://hub.docker.com/r/grafana/grafana)
[Node-Red](https://nodered.org) | [Node-Red](https://hub.docker.com/r/nodered/node-red)
[Mongo](https://mongodb.com) | [Mongo](https://hub.docker.com/_/mongo)
[Mongo-Express](https://github.com/mongo-express/mongo-express) | [Mongo Express](https://hub.docker.com/_/mongo-express)
[InfluxDb](https://www.influxdata.com) | [InfluxDb](https://hub.docker.com/_/influxdb)
[Mosquitto](https://mosquitto.org/) | [Mosquitto](https://hub.docker.com/_/eclipse-mosquitto)
[Portainer](https://www.portainer.io) | [Portainer](https://hub.docker.com/r/portainer/portainer-ce)
[Watchtower](https://containrrr.github.io/watchtower) | [Watchtower](https://hub.docker.com/r/containrrr/watchtower)

## Requirements

Currently, this installation has only been tested on Ubuntu 20.04 and greater, but should also work on 18.

It requires that you have root access (sudo) in order to install Docker and its pieces.

## :scroll: The Install script

*[ :point_right: You may want to read this entire README file prior to running the install script to determine if you would like to make modifications to the installation first. Custom settings can be made in the **.env** environment file or the **docker-compose.yaml** files listed below]*


Open up a terminal and chage directories to the location you downloaded the CIPio install files to. Run the install script

```
> ./install.sh
```

You do not need to initially run the script as root (sudu). The script will prompt you for your root password when it runs.

The first thing that the script does is try to determine if you have Docker installed on your system. If not, it will download and install Docker for you. If you are not familiar with docker, it is an application used to create and run containerized apps on your system. You can find out more about Docker [HERE](https://www.docker.com).

*[ :point_right: In the future, the CIPio isntallations may branch out into other container system such as [Podman](https://podman.io) which does not require the need to run at elevated/root levels in order to support containers, and [Kubernetes](https://kubernetes.io)]*

### Docker
CIPio also requires an additional Docker tool, Docker-Compose be installed. If Docker-Compose isn't automatically installed when Docker is install (at one point they needed to be installed seperately) then the install script will also download and install Docker-Compose.

### Adding you to the docker group

Once installed, you user will also be added to the "docker" user group on your system. This will keep you from having to sudu your account in order to do to certain docker activities. You may have to exit and restart your terminal in order for this to take affect.

### Choosing containers to install

At this point, the isntall script will prompt you for which containers you would like to have installed. By default, all the containers listed above are installed. You simply need to answer yes to the first prompt. Please note that not all variations of containers are installed. Initially, the only variation is which version of InfluxDb gets installed. By default Influx v1.8 is installed. If you wish to venture to the use the newer release, v2.0, then you should choose No on the first promt to "install all".

You may also wish to answer "no" to the "install all" question if you do not wish to install all of the containers. Perhaps you wish to skip the installation of Mongo (you do not want a [noSQL](http://en.wikipedia.org/wiki/NoSQL) type database) or do not want extra tools such as Mongo Express or Watchtower.

Answering "no" to the "install all" quesiton will then prompt you one by one if you wish to install each container. Keep in mind, you can always re-run the install script and install containers you skipped earlier. If you, say, answer no to installing Mongo and then later decide you want to install Mongo, just re-run the install script choose yes when prompted.

Running the script a second time and selecting "no" to a container that is already installed WILL NOT uninstall that container. The install script will only install containers. You will need to use Docker itself later, or a tool such as Portainer to stop, kill, and uninstall containers once they are installed.

## :scroll: The environment file (.env)
The docker environment file lets you customize certain aspects of the installation... [finish me]

## :scroll: The Docker-Compose file

## MQTT / Mosquitto
### customizations

## Node-Red
### customizations

## InfluxDB
### customizations

## MongoDB
### customizations

## Grafana
### customizations

## Portainer and Watchtower

Watchtower is: "A process for automating Docker container base image updates."
### customizations
