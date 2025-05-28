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

# esc Color text escape codes
# RED='\033[1;31m'
# GREEN='\033[1;32m'
# YELLOW='\033[1;33m' # Bold yellow
# BLUE='\033[1;34m'
# MAGENTA='\033[1;35m'
# CYAN='\033[1;36m'
# BRIGHTWHITE='\33[1;37m'
# NC='\033[0m' # No Color

# tput
BLINK=$(tput blink)
RESET=$(tput sgr0)
CLEAR=$(tput clear)
REV=$(tput rev)

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3) # Bold yellow
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
GRAY=$(tput setaf 8)

# Bold
BRIGHTWHITE=$(tput setaf 7 bold)
BRIGHTYELLOW=$(tput setaf 3 bold)
BRIGHTCYAN=$(tput setaf 6 bold)
BRIGHTBRIGHT=$(tput setaf 2 bold)

ERRORTEST=$(tput setaf 7 setab 1 bold)

# clear
NC=$(tput sgr0)

banner() {
  tput clear
  printf "${BRIGHTCYAN}"
  printf "   ______________    _      ${MAGENTA}    __    _       __      \n"
  printf "${BRIGHTCYAN}"
  printf "  / ____/  _/ __ \  (_)___  ${MAGENTA}   / /   (_)___  / /__    \n"
  printf "${BRIGHTCYAN}"
  printf " / /    / // /_/ / / / __ \ ${MAGENTA}  / /   / / __ \/ //_/    \n"
  printf "${BRIGHTCYAN}"
  printf "/ /____/ // ____/ / / /_/ / ${MAGENTA} / /___/ / / / / ,<       \n"
  printf "${BRIGHTCYAN}"
  printf "\____/___/_/   (_)_/\____/  ${MAGENTA}/_____/_/_/ /_/_/|_|      \n"
  printf "${BRIGHTCYAN}"
  printf "\n"
}

banner_lvl2() {
  local input_string="$1"
  local string_len=${#input_string}
  local line_len=$((${string_len} + 6))
  tput setaf 7 setab 2 bold
  printf "%*s\n" "$line_len" "" | tr ' ' '*'
  printf "** ${input_string} **\n"
  printf "%*s\n" "$line_len" "" | tr ' ' '*'
  tput sgr0
}

print_topline() {
  local input_string="$1"
  local input_str_len="${#input_string}"
  local term_len=$(tput cols)
  local line_len=$(($term_len - ${input_str_len} - 9))
  tput setaf 2 bold
  printf "|===> ${BRIGHTWHITE}${input_string} "
  tput setaf 2 bold
  printf "<"
  printf "%*s|\n" "$line_len" "" | tr ' ' '='
}

print_action() {
  local input_string="$1"
  printf "${GREEN}## %s${NC}\n" "${input_string}"
}

print_action_installing() {
  local input_string="$1"
  printf "${GREEN}=> ${REV}%s${NC}\n" "${input_string}"
}
