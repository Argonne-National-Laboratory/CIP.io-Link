#!/bin/bash
clear
# Default .env file path (make this configurable if needed)
ENV_FILE=".env"

# Color text escape codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m' # Bold yellow
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BRIGHTWHITE='\33[1;37m'
NC='\033[0m' # No Color

if [ ! -f $ENV_FILE ]; then
  touch $ENV_FILE
fi
# Function to display current .env settings (optional but helpful)
display_env_settings() {
  if [ ! -f $ENV_FILE ]; then
    touch $ENV_FILE
  fi
  echo "Current .env settings:"
  cat "$ENV_FILE"
  echo ""
}

# Function to update or add and environment variable in a .env file
update_or_add_env_variable() {
  local variable_name="$1"
  local variable_value="$2"

  # Escape slashes in the value for sed
  local escaped_value=$(printf '%s\n' "$variable_value" | sed 's|/|\\/|g')

  if grep -q "^${variable_name}=" "$ENV_FILE"; then
    # Variable exists, update it
    sed -i "s|^${variable_name}=.*|${variable_name}=${escaped_value}|" "$ENV_FILE"
    echo "Updated $variable_name to: $variable_value"
  else
    # Variable doesn't exist, add it
    echo "${variable_name}=$variable_value" >>"$ENV_FILE"
    echo "Added $variable_name with value: $variable_value"
  fi
}

# Function to update the valkey.conf with requirepass password

update_valkey_conf() {

  conf_file="./valkey/config/valkey.conf"

  mkdir -p ./valkey/config
  cp -f ./build/valkey/valkey.conf $conf_file
  new_password=$(egrep "CIPIO_VALKEY_PASSWORD?=" "$ENV_FILE" | cut -d "=" -f 2-)

  # the following line will allow for symbols in passwords
  escaped_password=$(printf '%s\n' "$new_password" | sed 's/[\/&]/\\&/g')
  echo -e "\n"
  # echo "VALKEY PASSWORD: $new_password"

  # Use sed to replace the requirepass line
  sed -i "s/^requirepass \".*\"$/requirepass \"$escaped_password\"/" "$conf_file"

}

# Function to prompt the user for input and update a specific variable
update_env_variable() {
  local variable_name="$1"
  local prompt_message="$2"

  current_value=$(grep "^${variable_name}=" "$ENV_FILE" | cut -d "=" -f 2-)

  read -p "$prompt_message (Current: ${current_value:-"not set"}): " new_value

  if [[ -z "$new_value" ]]; then
    new_value="$current_value"
    if [[ -z "$new_value" ]]; then
      echo "No input provided. Variable $variable_name will not be set."
      return
    fi
  fi

  # Escape slashes in the new value for sed
  escaped_new_value=$(printf '%s\n' "$new_value" | sed 's|/|\\/|g')

  if grep -q "^${variable_name}=" "$ENV_FILE"; then
    # Use a different delimiter in sed (e.g., '|') to avoid escaping
    sed -i "s|^${variable_name}=.*|${variable_name}=${escaped_new_value}|" "$ENV_FILE"
  else
    echo "${variable_name}=$new_value" >>"$ENV_FILE"
  fi

  # echo "$variable_name updated to: $new_value"
}

# Function to prompt for and update a variable if it doesn't exist
update_env_if_not_exists() {
  local variable_name="$1"
  local prompt_message="$2"

  if ! grep -q "^${variable_name}=" "$ENV_FILE"; then
    #NOTE use the -s option of read to hide input for passwords
    read -p "$prompt_message: " new_value # -s for silent input (passwords)
    echo ""                               # Add a newline after silent input
    echo "${variable_name}=$new_value" >>"$ENV_FILE"
    # echo "$variable_name added."
  fi
}

update_env_if_not_exists_with_default() {
  local variable_name="$1"
  local prompt_message="$2"
  local default_value="$3"

  if ! grep -q "^${variable_name}=" "$ENV_FILE"; then
    #NOTE use the -s option of read to hide input for passwords
    read -p "$prompt_message (default: $default_value): " new_value # -s for silent input (passwords)
    echo ""                                                         # Add a newline after silent input

    if [[ -z "$new_value" ]]; then
      new_value="$default_value" # Use the default if user enters nothing
    fi

    echo "${variable_name}=$new_value" >>"$ENV_FILE"
    # echo "$variable_name added."
  fi
}

# Generate a random password of length between 8 and 20 characters
length=$((RANDOM % 14 + 12)) # Random length between 8 and 20

# Generate password
# password=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+' </dev/urandom | head -c "$length")

password=$(tr -dc 'A-Za-z0-9!@#$%^&*_+' </dev/urandom | head -c "$length")

# Main script logic
# display_env_settings # Optional: Show current settings

echo -e "\n"
echo -e "\n"
echo -e "${YELLOW}===================CIPio Link Setup====================================================${NC}"
echo "To initially set up CIPio Link, please provide input to the following prompts."
echo "If a value is already set, it will be shown as \"Current\" and you can just hit return"
echo "to accept the exiting value."
echo -e "${YELLOW}=======================================================================================${NC}"
echo -e "\n"

## Username & Password
echo "Please provide a username and password that CIPio Link will use to configure various"
echo "applications. To keep things uncomplicated, CIPio Link uses a common user and password"
echo "where possible. Since various parts of CIPio Link run in conatiners, this isn't a"
echo "security issue."
echo -e "\n"
echo "NOTE: This is NOT the same user and password for the system login."
echo -e "\n"
update_env_variable "CIPIO_USER" "Enter the user name for CIPio Link"
update_env_variable "CIPIO_PW" "Enter the user password"

# CSMS Port and route
echo -e "\n"
echo -e "${YELLOW}=======================================================================================${NC}"
echo "We will now set up the port number and path that the CSMS will operate on."
echo "For example: "
echo -e "\n"
echo -e "     a port number of ${GREEN}8822${NC}"
echo -e "     and a path of ${GREEN}\"/ocpp\"${NC} "
echo -e "\n"
echo "...will set up the CSMS to accept incoming EVSE connections on:"
echo -e "\n"
echo -e "${CYAN}     \"ws://<host_ip>:8822/ocpp\".${NC} "
echo -e "\n"
echo "You will need to provide that URL to your EVSE."
echo "PLEASE NOTE: Refer to your EVSE operations manual to determine if the URL you"
echo "provide on the EVSE requires you to also append the station name. Many EVSEs"
echo "do that automatically for you when they connect."
echo -e "\n"
update_env_variable "CIPIO_CSMS_PORT" "Enter the port number you want your EVSEs to connect on"
update_env_variable "CIPIO_CSMS_PATH" "Enter the path you want your EVSEs to connect on"

# We need to read in the update .env file variables
source $ENV_FILE

currpath=$CIPIO_CSMS_PATH
# Ensure there is a leading slash and no ending slash
CIPIO_CSMS_PATH=${CIPIO_CSMS_PATH%/}

if [[ ! "$CIPIO_CSMS_PATH" =~ ^/ ]]; then
  CIPIO_CSMS_PATH="/$CIPIO_CSMS_PATH"
fi

# only update the .env file if the path has been modified from the users input.
if [[ "$currpath" != "$CIPIO_CSMS_PATH" ]]; then
  update_or_add_env_variable "CIPIO_CSMS_PATH" $CIPIO_CSMS_PATH
fi

echo -e "\n"
echo -e "${YELLOW}=======================================================================================${NC}"
echo "We've generated a random password for our in-memory database to use."
echo "If we have previously done this on an earlier setup, this will be skipped."
echo "You can accept the random password if prompted (recommended), or change it."
echo "Subsequent runs of this setup will not prompt for this again and simply"
echo "use the existing random password if it finds one."
echo -e "\n"
update_env_if_not_exists_with_default "CIPIO_VALKEY_PASSWORD" "Enter a random password for the in-memory database" "$password"

# display_env_settings # Optional: Show updated settings

# Update the valkey.conf file with the password
update_valkey_conf
