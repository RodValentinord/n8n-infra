#!/bin/bash
# k3s-server-init.sh — cloud-init user_data for K3s server (VM1)
# Injected by Terraform via metadata.user_data (base64-encoded).
set -euo pipefail

# TODO: Pin K3s version for reproducibility
K3S_VERSION="v1.29.3+k3s1"

# System update
apt-get update -qq && apt-get upgrade -y -qq

# Install K3s server (disable Traefik — Nginx Ingress will be deployed via Helm)
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_VERSION="${K3S_VERSION}" \
  sh -s - server \
    --disable traefik \
    --disable servicelb \
    --write-kubeconfig-mode 644

# TODO: Export K3S_TOKEN to OCI Secrets so agents can join without SSH access
# K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
