#!/usr/bin/env bash
set -euo pipefail

GITHUB_API="https://api.github.com/repos/posit-dev/positron/releases/latest"
CDN_BASE="https://cdn.posit.co/positron/releases"
DEST="/tmp/positron-server.tar.gz"

# Find latest Positron release
release=$(wget -qO- "$GITHUB_API" | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])")

# Get the checksums for the latest release
checksum_url="${CDN_BASE}/checksums/positron-${release}-checksums.json"
checksums=$(wget -qO- "$checksum_url")

filename="positron-server-linux-x64-${release}.tar.gz"
expected=$(echo "$checksums" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['${filename}'])")

download_url="${CDN_BASE}/server/x86_64/${filename}"

wget -q "$download_url" -O "$DEST"

# Verify SHA256 checksum
actual=$(sha256sum "$DEST" | awk '{print $1}')

if [ "$actual" != "$expected" ]; then
  echo "Checksum MISMATCH: expected $expected, got $actual" >&2
  rm -f "$DEST"
  exit 1
fi

# Install Positron Server
mkdir -p /opt/positron-server
tar -xzf "$DEST" -C /opt/positron-server --strip-components=1
rm "$DEST"
