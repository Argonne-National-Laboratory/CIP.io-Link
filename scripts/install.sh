#!/bin/bash

# source ./utils.sh
# Color text escape codes
# Normally we load this brom tuils.sh, but in this case we haven't gotten utils.sh het.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m' # Bold yellow
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BRIGHTWHITE='\33[1;37m'
NC='\033[0m' # No Color

clear
echo -e "${GREEN}********************************************${NC}"
echo -e "${GREEN}* ${CYAN}Starting CIP.io-Link Installation...   ${GREEN} *${NC}"
echo -e "${GREEN}********************************************${NC}"

echo -e "\n\n${GREEN}This script will install the CIP.io-Link CSMS application on your system.${NC}"
echo -e "\n"
echo -e "${GREEN}PRESS <ENTER> to continue. <Ctrl-c> to exit${NC}"
read

//sudo apt update

function install_docker() {
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo rm get-docker.sh
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo systemctl status docker
}

##############################
## Install Docker on Ubuntu ##
##############################
function install_docker2() {
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

}

## Check for curl installation
echo -e "${GREEN}## Checking for curl${NC}"

if ! command -v curl &>/dev/null; then
  echo "## curl Install #######################################################"
  sudo apt-get install curl
else
  echo "curl is installed"
fi

## Check for git installation
echo -e "${GREEN}## Checking for git${NC}"

if ! command -v git &>/dev/null; then
  echo "## git Install #######################################################"
  sudo apt-get install git
else
  echo "git is installed"
fi

## Clone the repository
git clone https://github.com/Argonne-National-Laboratory/CIP.io-Link.git
cd CIP.io-Link

## Check for jq installation
echo -e "${GREEN}## Checking for jq${NC}"

if ! command -v jq &>/dev/null; then
  echo "## jq Install #######################################################"
  sudo apt-get install jq
else
  echo "jq is installed"
fi

## Check for Docker installation
echo -e "${GREEN}## Checking for Docker${NC}"

if ! command -v docker &>/dev/null; then
  clear
  echo -e "${GREEN}## Docker Install #######################################################"
  echo -e "\n"
  echo -e "First we need to install Docker on your system.${CYAN} Hit <ENTER> to continue:${NC}"
  read

  install_docker2

  if hash docker 2>/dev/null; then
    echo "Docker now installed."
    sudo addgroup docker
    sudo usermod -aG docker ${USER}
  else
    error "Installation of Docker has failed. Exiting setup"
    exit 1
  fi
else
  echo "Docker is already installed"
  echo "Stopping any current CIP.io-Link containers"
  docker compose down
fi

./scripts/setup_env.sh
./scripts/setup_mqtt.sh
./scripts/setup_influx.sh
./scripts/setup_nr.sh
# docker compose --profile grafana up -d

cipiolnk_ver=$(git describe --tags --abbrev=0)
echo "CIPIO_LINK_VER=${cipiolnk_ver}" >.ver.env
cipiolnk_host=$(hostname -I | awk '{print $1}')
echo "CIPIO_LINK_HOST=${cipiolnk_host}" >>.ver.env
docker compose up -d

echo -e "\n\n ${WHITE}Setup Completed${NC}\n\n"
echo -e "${YELLOW}*******************************************************************${NC}"
echo -e "${GREEN} Go to http://${cipiolnk_host}:1880/dashboard to see the CIP.io-Link CSMS app${NC}"
echo -e "${YELLOW}*******************************************************************${NC}"
echo -e "\n\n"
