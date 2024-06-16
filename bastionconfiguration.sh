#!/bin/bash
apt update -y
export RELEASE="2.2.1"

useradd --no-create-home --shell /bin/false prometheus

useradd --no-create-home --shell /bin/false node_exporter

mkdir /etc/prometheus
mkdir /var/lib/prometheus

chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

cd /opt/
wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
sha256sum prometheus-2.26.0.linux-amd64.tar.gz
tar -xvf prometheus-2.26.0.linux-amd64.tar.gz

cd prometheus-2.26.0.linux-amd64 
cp /opt/prometheus-2.26.0.linux-amd64/prometheus /usr/local/bin/
cp /opt/prometheus-2.26.0.linux-amd64/promtool /usr/local/bin/

chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

cp -r /opt/prometheus-2.26.0.linux-amd64/consoles /etc/prometheus
cp -r /opt/prometheus-2.26.0.linux-amd64/console_libraries /etc/prometheus
cp -r /opt/prometheus-2.26.0.linux-amd64/prometheus.yml /etc/prometheus

chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown -R prometheus:prometheus /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /var/lib/prometheus
chmod -R 755 /var/lib/prometheus

sudo -u prometheus /usr/local/bin/prometheus \
        --config.file /etc/prometheus/prometheus.yml \
        --storage.tsdb.path /var/lib/prometheus/ \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries > /dev/null &

echo "setting up prometheus.service file"

cat >/etc/systemd/system/prometheus.service <<EOL
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
        --config.file /etc/prometheus/prometheus.yml \
        --storage.tsdb.path /var/lib/prometheus/ \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries 
        --web.listen-address=0.0.0.0:9090
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOL

echo "" >> /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
ufw allow 9090/tcp

# install node exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvf node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64
cp node_exporter /usr/local/bin
cd ..
rm -rf ./node_exporter-1.3.1.linux-amd64
useradd --no-create-home --shell /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo "setting up node_exporter.service file"
cat > /etc/systemd/system/node_exporter.service <<EOL
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

echo "" >> /etc/systemd/system/node_exporter.service
echo "restarting node exporter"

systemctl daemon-reload
systemctl start node_exporter

yes | apt update -y
echo "installing grafana"
apt install docker.io -y

docker pull grafana/grafana
docker run -d -p 3000:3000 --name=grafana grafana/grafana
