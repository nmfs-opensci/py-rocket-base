#!/usr/bin/env bash
set -euo pipefail

# Download Positron server to temporary directory.
# Note: this URL is for x86_64 (amd64) architecture only.
wget -q "https://cdn.posit.co/positron/releases/server/x86_64/positron-server-linux-x64-2026.05.0-179.tar.gz" \
    -O /tmp/positron-server.tar.gz

mkdir -p /opt/positron-server
tar -xzf /tmp/positron-server.tar.gz -C /opt/positron-server --strip-components=1
rm /tmp/positron-server.tar.gz
