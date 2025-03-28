#!/bin/bash
set -e

# Update and install dependencies
sudo apt update -y
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Start Minikube
sudo -u ubuntu minikube start --driver=docker

# Verify Installation
sudo -u ubuntu minikube status
