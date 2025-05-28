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

banner_lvl2 "Starting INfluxDB Setup..."
echo -e
# Function to check if jq is installed
check_jq_installed() {
  if ! command -v jq &>/dev/null; then
    printf "${MAGENTA}jq is not installed. Installing jq...${NC}\n"
    sudo apt update
    sudo apt install -y jq
  else
    printf "${MAGENTA}jq command is available.${NC}\n"
  fi
}

# Check if jq is installed and install if necessary
check_jq_installed

export INFLUX_DESC=cipio$(date +'%y%m%d%H%M')
export INFLUX_ORG=cipio

# Start up the influx container
docker compose up influx2 -d

# Loop until the app is ready
#
until curl -s http://localhost:8086/health | grep -q '"status":"pass"'; do
  echo -n "."
  sleep 2
done

# setup an initial user, org, and bucket
docker exec influx2 influx setup --username cipio --password cipio.lnk --org cipio --bucket ocpp_log --force

# going to sleep for a period of time since we don't know how to tell when setup is ready
#
# Initialize status code to a non-zero value
status=1

# Loop until the status code is 0 (indicating success)
while [ $status -ne 0 ]; do
  # Execute the command
  docker exec influx2 cat /etc/influxdb2/influx-configs >/dev/null 2>&1

  # Capture the status code of the command
  status=$?

  # Check if the command succeeded
  if [ $status -ne 0 ]; then
    printf "$(tput setaf 7 setab 1 bold)Command failed. Retrying...\n${NC}"
    sleep 5 # Wait for 5 seconds before retrying
  fi
done

# Continue with the rest of your script

# Capture the default operator token so we can do further setup
export INFLUX_TOKEN=$(docker exec influx2 cat /etc/influxdb2/influx-configs | grep -A 3 -B 3 cipio | grep token | awk -F\" '{print $2}')

# setup another couple of buckets
docker exec influx2 influx bucket create --name OCPP --retention 52w
docker exec influx2 influx bucket create --name meters --retention 52w

# List the buckets just for debugging purposes. This isn't necessary
docker exec influx2 influx bucket list

# Create an all access token that can be used by Node-Red
docker exec influx2 influx auth create --all-access -d ${INFLUX_DESC} >/dev/null 2>&1

# Save that token to our .env file so that it can be used by Node-Red or other CIPIO Link  containers
# export INFLUX_TOKEN=$(docker exec influx2 influx auth list --json | jq -r --arg desc "$INFLUX_DESC" '.[] | select(.description == $desc) | .token')
#
# echo $INFLUX_TOKEN
#
# Check if the .env file exists, if not create it
if [ ! -f .env ]; then
  touch .env
fi

# Update the INFLUX_TOKEN in the .env file or add it if it doesn't exist
if grep -q "CIPIO_INFLUX_TOKEN=" .env; then
  # If INFLUX_TOKEN exists, replace its value
  sed -i "s/^CIPIO_INFLUX_TOKEN=.*/CIPIO_INFLUX_TOKEN=${INFLUX_TOKEN}/" .env
else
  # If INFLUX_TOKEN does not exist, append it to the file
  echo "CIPIO_INFLUX_TOKEN=${INFLUX_TOKEN}" >>.env
fi
