#!/bin/bash

if ! command -v curl &>/dev/null; then
  echo "curl is required to download the installer"
else
  echo "curl is installed"
fi

if ! command -v docker &>/dev/null; then
  echo "docker is required"
else
  echo "docker is installed"
fi

if ! command -v git &>/dev/null; then
  echo "git is required"
else
  echo "git is installed"
fi

if ! command -v jq &>/dev/null; then
  echo "jq is required"
else
  echo "jq is installed"
fi
if ! command -v baddy &>/dev/null; then
  echo "baddy is required"
else
  echo "baddy is installed"
fi
