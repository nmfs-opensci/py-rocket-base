#!/bin/bash
set -euo pipefail

# Ensure script is being run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "pyrocket_scripts/install-geospatial-r.sh script must be run as root." >&2
  exit 1
fi

# Temporary R profile setup for system-wide library path
echo '.libPaths("/usr/local/lib/R/site-library")' > /etc/littler.r
echo '.libPaths("/usr/local/lib/R/site-library")' > /tmp/rprofile.site

# Run rocker-provided geospatial install script with temporary profile
R_PROFILE=/tmp/rprofile.site \
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
/rocker_scripts/install_geospatial.sh

# Cleanup
rm -f /etc/littler.r /tmp/rprofile.site
