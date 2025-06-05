#!/usr/bin/env bash

##################################################################################
# Copyright © 2025, UChicago Argonne, LLC
# All Rights Reserved
#
# Software Name: CIPio Link
# By: Argonne National Laboratory
#
# OPEN SOURCE LICENSE (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# •	The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##################################################################################

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

#
# Repo and defualts info
#
REPO_NAME="CIP.io-Link"
REPO_URL="https://github.com/Argonne-VCI/${REPO_NAME}.git"
BRANCH="main" # or "development"
QUICK=false

function show_help() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  -d, --debug            Enable debug mode"
  echo "  -q, --quick            Skip git update"
  echo "  -b, --branch <name>    git altername branch"
  echo "  -h, --help             Show this help message"
}

# Use getopt to parse options
TEMP=$(getopt -o dhqb: --long debug,help,quick,branch: -n 'install.sh' -- "$@")

# Check if getopt failed (invalid option)
if [ $? != 0 ]; then
  show_help
  exit 1
fi

# Reorder positional parameters based on parsed options
eval set -- "$TEMP"

# Parse options
while true; do
  case "$1" in
  -d | --debug)
    DEBUG=true
    shift
    ;;
  -q | --quick)
    QUICK=true
    shift
    ;;
  -b | --branch)
    BRANCH="$2"
    shift 2
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  --)
    shift
    break
    ;;
  *)
    # Should not reach here
    echo "Unexpected option: $1"
    show_help
    exit 1
    ;;
  esac
done

db_printf "DEBUG: ${DEBUG}"
db_printf "BRANCH: ${BRANCH}"
db_printf "QUICK: ${QUICK}"

# function install_docker() {
#   curl -fsSL https://get.docker.com -o get-docker.sh
#   sudo sh get-docker.sh
#   sudo rm get-docker.sh
#   sudo systemctl start docker
#   sudo systemctl enable docker
#   sudo systemctl status docker
# }

##############################
## Install Docker on Ubuntu ##
##############################
function install_docker() {
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

tput clear
banner

banner_lvl2 "Starting CIP.io-Link Installation"

printf "\n${GREEN}This script will install the CIP.io-Link CSMS application on your system.\n"
printf "\n"
printf "PRESS ${REV}<ENTER>${NC}${GREEN} to continue. <Ctrl-c> to exit${NC} "
read

## Check for curl installation
print_action "Checking for curl"

if ! command -v curl &>/dev/null; then
  print_action_installing "curl"
  sudo apt-get install curl
else
  printf "curl is installed\n"
fi

print_action "Checking for whois"
if ! command -v mkpasswd &>/dev/null; then
  print_action_installing "whois"
  sudo apt-get install whois
else
  printf "whois is installed\n"
fi

## Check for git installation
print_action "Checking for git"

if ! command -v git &>/dev/null; then
  print_action_installing "git"
  sudo apt-get install git
else
  printf "git is installed\n"
fi

## Clone the repository
# git clone https://github.com/Argonne-vci/CIP.io-Link.git

#####################
## Direcotry Check and git clone
##
## Is this script...
## - In a folder by the name of $REPO_NAME
##   -- YES: Does this folder have a .git folder
##      -- YES: Do a reset --hard
##      -- NO: Do a clone
##   -- NO: Does this folder contain a folder names $REPO_NAME
##      -- YES: Does this folder have a .git folder
##         -- YES: Do a reset --hard
##         -- NO: Do a clone
##      -- NO: Do a clone

# Get the current directory name
current_dir_name="${PWD##*/}"

# Check if the directory is named "cipio"
if [[ "$current_dir_name" == "${REPO_NAME}" ]]; then
  # Check if .git directory exists
  if [[ -d ".git" ]]; then
    if [[ $DEBUG == true ]]; then
      printf "In '${REPO_NAME}' and .git directory exists.\n"
      printf "Doing a git reset --hard\n"
    fi
    if [[ $QUICK != true ]]; then
      git fetch origin
      git reset --hard "origin/$BRANCH"
    fi
  else
    if [[ $DEBUG == true ]]; then
      printf "In '${REPO_NAME}' but .git directory does not exist.\n"
      printf "git clone into current direcotry\n"
    fi
    git clone --branch "$BRANCH" "$REPO_URL" .
  fi
else
  if [[ -d $REPO_NAME ]]; then
    cd $REPO_NAME || exit
    if [[ -d ".git" ]]; then
      if [[ $DEBUG == true ]]; then
        printf "In '${REPO_NAME}' and .git directory exists.\n"
        printf "Doing a git reset --hard\n"
      fi
      if [[ $QUICK != true ]]; then
        git fetch origin
        git reset --hard "origin/$BRANCH"
      fi
    else
      if [[ $DEBUG == true ]]; then
        printf "In '${REPO_NAME}' but .git directory does not exist.\n"
      fi
      # Put alternative logic here
    fi
  else
    git clone --branch "$BRANCH" "$REPO_URL"
    cd $REPO_NAME || exit
  fi
fi

# if [ ! -d "$REPO_NAME/.git" ]; then
#   print_action "Cloning repository..."
#   git clone --branch "$BRANCH" "$REPO_URL" "$REPO_NAME"
# else
#   print_action "Updating existing setup..."
#   cd "$REPO_NAME" || exit 1
#   git fetch origin
#   git reset --hard "origin/$BRANCH"
# fi

## Check for jq installation
print_action "Checking for jq"

if ! command -v jq &>/dev/null; then
  print_action_installing "jq"
  sudo apt-get install jq
else
  printf "jq is installed\n"
fi

## Check for Docker installation
print_action "Checking for Docker"

if ! command -v docker &>/dev/null; then
  print_action_installing "Docker"
  printf "Docker doesn't appear to be installed on your system.${CYAN} Hit <ENTER> to install Docker:${NC} "
  read

  install_docker

  if hash docker 2>/dev/null; then
    printf "Docker now installed.\n"
    sudo addgroup docker
    sudo usermod -aG docker ${USER}
  else
    error "Installation of Docker has failed. Exiting setup"
    exit 1
  fi
else
  printf "Docker is installed on this system\n"
  print_action "Stopping any current CIP.io-Link containers"
  docker compose down
fi

sudo ./scripts/setup_env.sh
sudo ./scripts/setup_mqtt.sh
sudo ./scripts/setup_influx.sh
sudo ./scripts/setup_nr.sh
# docker compose --profile grafana up -d

cipiolnk_ver=$(git describe --tags --abbrev=0)
echo "CIPIO_LINK_VER=${cipiolnk_ver}" >.ver.env
cipiolnk_host=$(hostname -I | awk '{print $1}')
echo "CIPIO_LINK_HOST=${cipiolnk_host}" >>.ver.env
sudo docker compose up -d

printf "\n\n ${REV}${RED} ${GREEN}  ${BLUE}   ${WHITE} Setup Completed ${BLUE}   ${GREEN}  ${RED} ${NC}\n\n"
printf "${BRIGHTYELLOW}*****************************************************************************\n"
printf "${BRIGHTGREEN} Go to http://${cipiolnk_host}:1880/dashboard to see the CIP.io-Link CSMS app\n"
printf "${BRIGHTYELLOW}*****************************************************************************\n"
printf "${NC}\n\n"
