#!/bin/bash

# Update package lists and install necessary packages
echo "Updating package lists and installing required packages..."
sudo apt-get update -y
sudo apt-get install -y wget tar

# Create node_exporter user if it doesn't already exist
if ! id "node_exporter" &>/dev/null; then
    sudo useradd --no-create-home --shell /bin/false node_exporter
fi

# Download and set up Node Exporter
NODE_EXPORTER_VERSION="1.3.1"
NODE_EXPORTER_FILE="node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/$NODE_EXPORTER_FILE"

cd /opt/
if [ ! -f $NODE_EXPORTER_FILE ]; then
    echo "Downloading Node Exporter..."
    wget $NODE_EXPORTER_URL &
    wait $! # Wait for download to complete
    tar -xzf $NODE_EXPORTER_FILE &
fi

# Move and set up Node Exporter
wait # Ensure all background tasks are complete
echo "Installing Node Exporter..."
sudo mv "node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter" /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Clean up extracted files
echo "Cleaning up extracted files..."
rm -rf "node_exporter-$NODE_EXPORTER_VERSION.linux-amd64"

# Set up node_exporter.service
echo "Setting up Node Exporter systemd service..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'EOL'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload &
sudo systemctl enable node_exporter &
sudo systemctl start node_exporter &
sudo ufw allow 9100/udp &

echo "Node Exporter setup completed."
