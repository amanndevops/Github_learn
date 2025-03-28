#!/bin/bash
set -e

# Update & install dependencies
sudo apt update -y
sudo apt install -y apt-transport-https software-properties-common wget curl tar

# Install Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

# Create systemd service for Node Exporter
cat <<NODE_EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=default.target
NODE_EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Install Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar -xvf prometheus-2.52.0.linux-amd64.tar.gz
sudo mv prometheus-2.52.0.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-2.52.0.linux-amd64/promtool /usr/local/bin/

# Create Prometheus service
cat <<PROM_EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/
Restart=always

[Install]
WantedBy=default.target
PROM_EOF

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

cat <<PROM_CFG | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
PROM_CFG

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Install Grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt update -y
sudo apt install grafana -y
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "Installation Completed. Access Grafana at http://<EC2-Public-IP>:3000"
