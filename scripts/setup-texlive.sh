#!/bin/bash
set -euo pipefail

echo "Running setup-texlive.sh"

# Background: When users install packages, make those go to a user library in /home not in /opt/texlive which is ephemeral

cat <<'EOF' > /etc/profile.d/texlive-user.sh
# Ensure tlmgr always uses user mode
alias tlmgr='tlmgr --usermode'

# Set user-specific TEXMF paths
export TEXMFHOME="$HOME/texmf"

# Auto-init user tree if not already done
if [ ! -f "$HOME/texmf/tlpkg/texlive.tlpdb" ]; then
    echo "[texlive-user] Initializing user TeX Live tree..."
    tlmgr --usermode init-usertree
fi
EOF

# Make it executable (not strictly necessary for profile.d)
chmod +x /etc/profile.d/texlive-user.sh
