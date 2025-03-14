#!/bin/bash

# Default values for optional environment variables
INFISICAL_API_URL=${INFISICAL_API_URL:-"https://eu.infisical.com"}
if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ] || [ -z "$PROJECT_ID" ] || [ -z "$BASE_DIR" ] ; then
  echo "Error: Required environment variables not set."
  echo "Usage: CLIENT_ID=xxx CLIENT_SECRET=xxx PROJECT_ID=xxx [INFISICAL_API_URL=url] [BASE_DIR=path] bash $0"
  exit 1
fi

mkdir -p "$BASE_DIR"

