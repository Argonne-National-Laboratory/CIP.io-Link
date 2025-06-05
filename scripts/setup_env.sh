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

# Default .env file path (make this configurable if needed)
ENV_FILE=".env"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

banner

# Create the environment file if it doesn't exist
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
  local escaped_value

  escaped_value=$(printf '%s\n' "$variable_value" | sed 's|/|\\/|g')

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

  new_password=${new_password//\'/}

  # the following line will allow for symbols in passwords
  escaped_password=$(printf '%s\n' "$new_password" | sed 's/[\/&]/\\&/g')
  # echo -e "\n"
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

prompt_for_secret() {
  local variable_name="$1"
  local prompt_message="$2"
  # local ENV_FILE=".env2"

  # Load existing value if present
  local current_value
  if [[ -f "$ENV_FILE" ]]; then
    current_value=$(grep "^${variable_name}=" "$ENV_FILE" | sed -E "s/^${variable_name}=\"?([^\"]*)\"?/\1/")
  fi

  # Loop until the user enters matching passwords or cancels
  while true; do
    if [[ -n "$current_value" ]]; then
      echo -n "${prompt_message} [Leave empty to keep current value]: "
      read -s first
      if [[ -z "$first" ]]; then
        return 0
      fi
    else
      echo -n "${prompt_message}: "
      read -s first
    fi
    echo
    echo -n "Confirm new password: "
    read -s second
    echo

    if [[ "$first" != "$second" ]]; then
      echo "Values do not match. Try again or press Ctrl+C to cancel."
    else
      # Encrypt the value
      if ! command -v mkpasswd &>/dev/null; then
        echo "mkpasswd not found. Please install 'whois' or the required package."
        exit 1
      fi
      encrypted=$(mkpasswd -m bcrypt "$first")

      # Escape slashes in the new value for sed
      escaped_new_value=$(printf '%s\n' "$encrypted" | sed 's|/|\\/|g')

      if grep -q "^${variable_name}=" "$ENV_FILE"; then
        # Use a different delimiter in sed (e.g., '|') to avoid escaping
        sed -i "s|^${variable_name}=.*|${variable_name}=${escaped_new_value}|" "$ENV_FILE"
      else
        echo "${variable_name}=$new_value" >>"$ENV_FILE"
      fi
      return 0
    fi
  done
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

    # We are wrapping this in single quotes to handle the special chars
    echo "${variable_name}='$new_value'" >>"$ENV_FILE"
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
banner
printf "${GREEN}===================CIP.io Link Setup====================================================${NC}\n"
printf "To set up CIP.io Link, please provide input to the following prompts.\n"
printf "If a value is already set, it will be shown as \"Current\" and you can just hit return\n"
printf "to keep the exiting value.\n"
printf "${GREEN}=======================================================================================${NC}\n"
printf "\n\n"
read -p "Hit Enter to continue: " xyz

## Username & Password
banner
printf "${YELLOW}==| ${CYAN}CIP.io Link Admin Info${YELLOW} |=================================================================${NC}\n"
printf "Please provide a username and password that CIP.io Link will use to configure various\n"
printf "applications. To keep things uncomplicated, CIP.io Link uses a common user and password\n"
printf "where possible. Since various parts of CIP.io Link run in containers, this isn't a\n"
printf "security issue.\n"
printf "\n${RED}NOTE:${NC} This is NOT the Linux system username and password.\n"
printf "      This is used for logging into the Node-Red programming interface and for any containers\n"
printf "      that expect a username and password for security reasons.\n"
printf "\n   ${CYAN}(You will be prompted for a user login info in the next section)${NC}\n\n"
update_env_variable "CIPIO_USER" "Enter Admin Username"
# update_env_variable "CIPIO_PW" "Enter Admin password:"
prompt_for_secret "CIPIO_PW" "Enter Admin Password"

# Username and Password for the CSMS Web user
banner
printf "${YELLOW}==| ${CYAN}CIP.io Link User Info${YELLOW} |=================================================================${NC}\n"
printf "Please provide a username and password that will be used to access the CSMS web interface\n"
printf "\n\n"
update_env_variable "CIPIO_UI_USER" "Enter Username"
prompt_for_secret "CIPIO_UI_PW" "Enter User Password"

# CSMS Port and route
banner
printf "\n\n"
printf "${YELLOW}==| ${CYAN}CSMS Port and Route${YELLOW} |==================================================================${NC}\n"
printf "We will now set up the port number and path that the CSMS will listen on.\n"
printf "\n\n"
printf "For example: \n"
printf "     a port number of ${GREEN}8822${NC}\n"
printf "     and a path of ${GREEN}\"/ocpp\"${NC} \n"
printf "\n\n"
printf "...will set up the CSMS to accept incoming EVSE connections on:\n"
printf "\n\n"
printf "${CYAN}     \"ws://<host_ip>:${GREEN}8822/ocpp${NC}\".${NC} \n"
printf "\n\n"
printf "You will need to provide that URL to your EVSE.\n"
printf "\n${RED}NOTE:${NC} Refer to your EVSE operations manual to determine if the URL you\n"
printf "provide to the EVSE requires you to also append the station name. Many EVSEs\n"
printf "do that automatically for you when they connect.\n"
printf "\n\n"
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

# Prompt for ValKey Token
banner
printf "${YELLOW}==| ${CYAN}VALKEY Token${YELLOW} |===========================================================================${NC}\n"
printf "We've generated a random password for our in-memory database to use.\n"
printf "If we have previously done this on an earlier setup, this will be skipped.\n"
printf "You can accept the random password if prompted (recommended), or change it.\n"
printf "Subsequent runs of this setup will not prompt for this again and simply\n"
printf "use the existing random password if it finds one.\n"
printf "\n\n"
update_env_if_not_exists_with_default "CIPIO_VALKEY_PASSWORD" "Enter a random password for the in-memory database" "$password"

# display_env_settings # Optional: Show updated settings

# Update the valkey.conf file with the password
update_valkey_conf

printf "${GREEN}Finished! ${NC}\n"
