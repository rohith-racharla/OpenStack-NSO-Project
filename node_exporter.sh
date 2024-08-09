#!/bin/bash

# Update package lists
sudo apt-get update -y

# Install necessary packages
echo "Installing required packages"
sudo apt-get install -y wget tar

# Download and extract Node Exporter
echo "Downloading Node Exporter"
NODE_EXPORTER_VERSION="1.3.1"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
wget "${DOWNLOAD_URL}"
tar -xzf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

# Move Node Exporter binary to a system directory
echo "Moving Node Exporter binary"
sudo mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/

# Clean up extracted files
echo "Cleaning up extracted files"
rm -rf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64"

# Create a dedicated user for Node Exporter
echo "Creating a dedicated user for Node Exporter"
sudo useradd --no-create-home --shell /bin/false node_exporter

# Set permissions for Node Exporter binary
echo "Setting permissions for Node Exporter binary"
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create a systemd service file for Node Exporter
echo "Creating a systemd service file for Node Exporter"
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

# Reload systemd daemon and start Node Exporter
echo "Reloading systemd daemon and starting Node Exporter"
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "Node Exporter is now running"
