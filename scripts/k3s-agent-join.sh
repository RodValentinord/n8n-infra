#!/bin/bash
# k3s-agent-join.sh — cloud-init user_data for K3s agents (VM2, VM3)
# Injected by Terraform via metadata.user_data (base64-encoded).
set -euo pipefail

K3S_VERSION="v1.29.3+k3s1"

# TODO: Retrieve these values from OCI Secrets Manager or SSM at boot time.
#       Do NOT hardcode server IP or token here.
K3S_SERVER_IP="TODO: server-private-ip"
K3S_TOKEN="TODO: retrieve-from-secrets"

apt-get update -qq && apt-get upgrade -y -qq

curl -sfL https://get.k3s.io | \
  INSTALL_K3S_VERSION="${K3S_VERSION}" \
  K3S_URL="https://${K3S_SERVER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -s - agent
