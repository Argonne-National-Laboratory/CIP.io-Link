#!/bin/bash

sudo apt update

function install_docker() {
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo rm get-docker.sh
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo systemctl status docker
}

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

if ! command -v curl &>/dev/null; then
  echo "curl is required to download the installer"
  sudo apt-get install curl
else
  echo "curl is installed"
fi

if ! command -v git &>/dev/null; then
  echo "git is required"
  sudo apt-get install git
else
  echo "git is installed"
fi

if ! command -v docker &>/dev/null; then
  echo "We need to first install Docker on your system. Hit <ENTER> to continue:"
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
fi

if ! command -v jq &>/dev/null; then
  echo "jq is required"
  sudo apt-get install jq
else
  echo "jq is installed"
fi
