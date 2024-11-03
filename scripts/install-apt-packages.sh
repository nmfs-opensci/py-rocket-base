#!/bin/bash
/scripts/copy-files.sh

echo "Checking for apt.txt..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "apt.txt"; then
    package_list=$(grep -v '^\s*#' apt.txt | grep -v '^\s*$' | sed 's/\r//g; s/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' | awk '{$1=$1};1')
    apt-get update --fix-missing > /dev/null
    apt-get install --yes --no-install-recommends $package_list
    apt-get autoremove --purge
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi
