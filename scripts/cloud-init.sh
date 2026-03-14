#!/bin/bash
# cloud-init.sh — Bootstrap script for all VMs.
# Installs packages required by K3s; actual K3s setup happens later.
set -euo pipefail

dnf install -y curl iptables
