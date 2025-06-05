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

banner_lvl2 "Starting MQTT Setup..."

# Source the .env file
if [[ -f .env ]]; then
  source .env
else
  printf "${ERRORTEXT}ERROR: .env file not found.\n${NC}"
  exit 1
fi

if [ -z "$CIPIO_USER" ] || [ -z "$CIPIO_PW" ]; then
  printf "${ERRORTEXT}Either the cipio user or password is not defined.\n"
  printf "Exiting setup\n${NC}"
  exit 1
fi

wait_for_container() {
  local container_name="$1"
  local timeout=60 # Timeout in seconds

  local start_time
  start_time=$(date +%s)

  while true; do
    local current_time

    current_time=$(date +%s)

    local elapsed_time=$((current_time - start_time))

    if [[ "$elapsed_time" -gt "$timeout" ]]; then
      printf "${ERRORTEXT}Timeout waiting for container '$container_name'.\n${NC}"
      docker logs "$container_name" 2>/dev/null
      return 1 # Indicate failure
    fi

    local running
    running=$(docker inspect --format='{{json .State.Running}}' "$container_name" 2>/dev/null | tr -d '"')

    echo $running

    if [[ "$running" == "true" ]]; then
      printf "Container '$container_name' is running.\n"
      return 0 # Indicate success
    ##TODO: Fix missing health variable
    elif [[ "$health" == "unhealthy" ]]; then
      printf "Container ${MAGENTA} '${container_name}'${NC} is not yet running. Checking again...\n"
      sleep 2
    fi
  done
}

if [[ "$EUID" != 0 ]]; then
  printf "${GREEN}We need to elevate you to root level for this installation. Please enter the sudo user password\n${NC}"
  sudo -k
  if sudo true; then
    printf "${GREEN}${REV}Good, you are now have sudo level access\n${NC}"
  else
    error "Incorrect password.. Exiting installation process"
  fi
fi

docker stop mqtt

dest=./mqtt/config

# Cretate the mqtt folder if it doesn't exist already
sudo mkdir -p $dest

# copy the default config file and create a password and acl file
sudo cp build/mqtt/mosquitto.conf mqtt/config
sudo touch $dest/mosquitto.pwd
sudo chmod 700 $dest/mosquitto.pwd
sudo touch $dest/mosquitto.acl
echo -e "user $CIPIO_USER\ntopic readwrite #\ntopic read \$SYS/#" | sudo tee $dest/mosquitto.acl >/dev/null

# Start up mqtt again so we can make execute the mosqitto_passwd command
docker compose up mqtt -d

container_name=mqtt
if wait_for_container "$container_name"; then
  printf "Container ${MAGENTA}'$container_name'${NC} is ready. Performing actions...\n"
  # Mosquitto (will) require the password file be owned by root
  docker exec mqtt chown root:root /mosquitto/config/mosquitto.pwd
  docker exec mqtt mosquitto_passwd -b -c /mosquitto/config/mosquitto.pwd $CIPIO_USER $CIPIO_PW
  # Restart mqtt to pick up the users and acls
  docker compose restart mqtt
else
  printf "${ERRORTEXT}Failed to start container '$container_name' properly.\n${NC}"
  docker rm -f "$container_name"
  exit 1
fi
