#!/bin/bash

SOURCE_DIR="./"  
DEPLOYR_SCRIPT="deployr.sh"
DEPLOYR_SERVICE="deployr.service"
DEPLOYR_TIMER="deployr.timer"

TARGET_SCRIPT="/usr/local/bin/$DEPLOYR_SCRIPT"
TARGET_SERVICE="/etc/systemd/system/$DEPLOYR_SERVICE"
TARGET_TIMER="/etc/systemd/system/$DEPLOYR_TIMER"

echo "Copying $DEPLOYR_SCRIPT to $TARGET_SCRIPT"
sudo cp "$SOURCE_DIR$DEPLOYR_SCRIPT" "$TARGET_SCRIPT"

echo "Copying $DEPLOYR_SERVICE to $TARGET_SERVICE"
sudo cp "$SOURCE_DIR$DEPLOYR_SERVICE" "$TARGET_SERVICE"

echo "Copying $DEPLOYR_TIMER to $TARGET_TIMER"
sudo cp "$SOURCE_DIR$DEPLOYR_TIMER" "$TARGET_TIMER"

echo "Setting permissions for $TARGET_SCRIPT"
sudo chmod 755 "$TARGET_SCRIPT"

echo "Setting permissions for $TARGET_SERVICE"
sudo chmod 644 "$TARGET_SERVICE"

echo "Setting permissions for $TARGET_TIMER"
sudo chmod 644 "$TARGET_TIMER"

echo "Enabling and starting the service and timer"
sudo systemctl enable deployr.service
sudo systemctl start deployr.service
sudo systemctl enable deployr.timer
sudo systemctl start deployr.timer

echo "Setup completed successfully."
