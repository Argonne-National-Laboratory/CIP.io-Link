#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

echo -e "${GREEN}********************************************${NC}"
echo -e "${GREEN}* ${CYAN}Starting MQTT setup...   ${GREEN}               *${NC}"
echo -e "${GREEN}********************************************${NC}"
# Source the .env file
if [[ -f .env ]]; then
  source .env
else
  echo ".env file not found."
  exit 1
fi

if [ -z "$CIPIO_USER" ] || [ -z "$CIPIO_PW" ]; then
  echo -e "${RED}Either the cipio user or password is not defined."
  echo -e "Exiting setup${NC}"
  exit 1
fi

wait_for_container() {
  local container_name="$1"
  local timeout=60 # Timeout in seconds

  local start_time=$(date +%s)

  while true; do
    local current_time=$(date +%s)
    local elapsed_time=$((current_time - start_time))

    if [[ "$elapsed_time" -gt "$timeout" ]]; then
      echo -e "${RED}Timeout waiting for container '$container_name'.${NC}"
      docker logs "$container_name" 2>/dev/null
      return 1 # Indicate failure
    fi

    local running=$(docker inspect --format='{{json .State.Running}}' "$container_name" 2>/dev/null | tr -d '"')

    echo $running

    if [[ "$running" == "true" ]]; then
      echo "Container '$container_name' is running."
      return 0 # Indicate success
    elif [[ "$health" == "unhealthy" ]]; then
      echo -e "${MAGENTA}Container '$container_name' is not yet running. Checking again...${NC}"
      sleep 2
    fi
  done
}

if [[ "$EUID" != 0 ]]; then
  echo -e "${GREEN}We need to elevate you to root level for this installation. Please enter the sudo user password${NC}"
  sudo -k
  if sudo true; then
    echo -e "${GREEN}Good, you are now have sudo level access${NC}"
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
  echo "Container '$container_name' is ready. Performing actions..."
  # Mosquitto (will) require the password file be owned by root
  docker exec mqtt chown root:root /mosquitto/config/mosquitto.pwd
  docker exec mqtt mosquitto_passwd -b -c /mosquitto/config/mosquitto.pwd $CIPIO_USER $CIPIO_PW
  # Restart mqtt to pick up the users and acls
  docker compose restart mqtt
else
  echo -e "${RED}Failed to start container '$container_name' properly.${NC}"
  docker rm -f "$container_name"
  exit 1
fi
