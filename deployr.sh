#!/bin/bash

# Load environment variables from .env file
if [ -f "/root/deployr/.env" ]; then
  source /root/deployr/.env
else
  echo "Error: .env file not found"
  exit 1
fi

# Set default value for INFISICAL_API_URL if not set
INFISICAL_API_URL="${INFISICAL_API_URL:-https://app.infisical.com}"

BASE_DIR="/root/deployr/$DOCKER_COMPOSE_PATH"
cd "$BASE_DIR" || exit 1

fetch_infisical_secrets() {

  # Check if required variables are set
  if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" || -z "$PROJECT_ID" ]]; then
    echo "Skipping Infisical secret fetch: Missing CLIENT_ID, CLIENT_SECRET, or PROJECT_ID"
    return
  fi

  echo "Logging in to Infisical..."
  export INFISICAL_TOKEN=$(infisical login --method=universal-auth --client-id="$CLIENT_ID" --client-secret="$CLIENT_SECRET" --silent --plain --domain "$INFISICAL_API_URL")


  echo "Fetching root secrets..."
  infisical export --env=prod --projectId="$PROJECT_ID" --domain "$INFISICAL_API_URL" > ".secrets"

  # Iterate through subdirectories and fetch secrets
  for dir in */; do
    if [ -d "$dir" ]; then
      echo "Processing directory: $dir"
      infisical export --env=prod --path="/$dir" --projectId="$PROJECT_ID" --domain "$INFISICAL_API_URL" > "$dir/.secrets"

      if [ $? -eq 0 ]; then
        echo "Export successful for directory: $dir"
      else
        echo "Error: Export failed for directory: $dir"
      fi
    else
      echo "Skipping non-directory: $dir"
    fi
  done
}

# Function to fetch new code and restart services if needed
update_and_apply_code() {
  git fetch

  if [ "$(git rev-list HEAD...origin/main --count)" -gt 0 ]; then
    echo "New commits found. Pulling changes..."
    git pull origin main
    docker-compose -f "$BASE_DIR/docker-compose.yaml" up -d
  else
    echo "No new commits found."
  fi
}

# Execute functions
fetch_infisical_secrets
update_and_apply_code

echo "Done"

