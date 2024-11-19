#!/bin/bash
# Required user: root
# The default for XDG and xfce4 is for Desktop files to be in ~/Desktop but this leads to a variety of problems
# First we are altering the user directiory which seems rude, second orphan desktop files might be in ~/Desktop so who knows
# what the user Desktop experience with be, here the Desktop dir is set to /usr/share/Desktop so is part of the image.
# users that want to customize Desktop can change /etc/xdg/user-dirs.dirs though py-rocket resets that each time the server is restarted.
set -e

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "  Error: This setup-desktop.sh must be run as root. Please use 'USER root' in your Dockerfile before running this script."
    echo "  Remember to switch back to the non-root user with 'USER ${NB_USER}' after running this script."
    exit 1
fi

# Copy in the Desktop files
APPLICATIONS_DIR=/usr/share/applications/packages
DESKTOP_DIR=/usr/share/Desktop
mkdir -p "${APPLICATIONS_DIR}"
mkdir -p "${DESKTOP_DIR}"
chown :staff /usr/share/Desktop
chmod 775 /usr/share/Desktop
# set the Desktop dir default for XDG
# this is likely not used. It would be used in xdg-user-dirs-update, but that is not run. Doesn't seem to set up /etc/xdg/user-dirs.dirs correctly
echo "DESKTOP=\"${DESKTOP_DIR}\"" > /etc/xdg/user-dirs.defaults

# The for loops will fail if they return null (no files). Set shell option nullglob
shopt -s nullglob

for desktop_file_path in ${REPO_DIR}/Desktop/*.desktop; do
    cp "${desktop_file_path}" "${APPLICATIONS_DIR}/."

    # Symlink application to desktop and set execute permission so xfce (desktop) doesn't complain
    desktop_file_name="$(basename ${desktop_file_path})"
    # Set execute permissions on the copied .desktop file
    chmod +x "${APPLICATIONS_DIR}/${desktop_file_name}"
    ln -sf "${APPLICATIONS_DIR}/${desktop_file_name}" "${DESKTOP_DIR}/${desktop_file_name}"
done
update-desktop-database "${APPLICATIONS_DIR}"

# Add MIME Type data from XML files  to the MIME database.
MIME_DIR="/usr/share/mime"
MIME_PACKAGES_DIR="${MIME_DIR}/packages"
mkdir -p "${MIME_PACKAGES_DIR}"
for mime_file_path in ${REPO_DIR}/Desktop/*.xml; do
    cp "${mime_file_path}" "${MIME_PACKAGES_DIR}/."
done
update-mime-database "${MIME_DIR}"

# Add icons
ICON_DIR="/usr/share/icons/hicolor"
ICON_SIZES=("16x16" "22x22" "24x24" "32x32" "48x48")

# Copy PNG icons only to existing size directories
for icon_file_path in "${REPO_DIR}"/Desktop/*.png; do
    for size in "${ICON_SIZES[@]}"; do
        target_dir="${ICON_DIR}/${size}/apps"
        if [ -d "${target_dir}" ]; then
            cp "${icon_file_path}" "${target_dir}/$(basename "${icon_file_path}")" || echo "Failed to copy ${icon_file_path} to ${target_dir}"
        else
            echo "Directory ${target_dir} does not exist. Skipping."
        fi
    done
done

# Copy SVG icons only to the existing scalable directory, if it exists
target_dir="${ICON_DIR}/scalable/apps"
for icon_file_path in "${REPO_DIR}"/Desktop/*.svg; do
    if [ -d "${target_dir}" ]; then
        cp "${icon_file_path}" "${target_dir}/$(basename "${icon_file_path}")" || echo "Failed to copy ${icon_file_path} to ${target_dir}"
    else
        echo "Directory ${target_dir} does not exist. Skipping SVG."
    fi
done
# Update the icon cache for hicolor
gtk-update-icon-cache "${ICON_DIR}"
# Print a success message
echo "Icons have been copied to existing hicolor directories, and the icon cache has been updated."

