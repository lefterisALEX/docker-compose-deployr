#!/bin/bash

TARGET_SCRIPT="/usr/local/bin/deployr.sh"
TARGET_SERVICE="/etc/systemd/system/deployr.service"
TARGET_TIMER="/etc/systemd/system/deployr.timer"

sudo cp "deployr.sh" "$TARGET_SCRIPT"

sudo cp "./systemd/deployr.service" "$TARGET_SERVICE"

sudo cp "./systemd/deployr.timer" "$TARGET_TIMER"

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


