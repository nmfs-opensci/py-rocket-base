# Define the target directory
TARGET_DIR="/home/${NB_USER}/.local"

# Change ownership only for items not owned by ${NB_USER}
sudo find "${TARGET_DIR}" ! -user "${NB_USER}" -exec chown "${NB_USER}:${NB_USER}" {} \;

# Set permissions on all directories: read, write, and execute for ${NB_USER}
sudo find "${TARGET_DIR}" -type d -exec chmod 755 {} \;

# Set permissions on all files: read and write for ${NB_USER}
sudo find "${TARGET_DIR}" -type f -exec chmod 644 {} \;
