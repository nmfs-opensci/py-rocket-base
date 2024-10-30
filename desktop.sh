# set the Desktop dir to something in base
echo 'XDG_DESKTOP_DIR="/usr/share/Desktop"' > /etc/xdg/user-dirs.defaults

# Copy in the Desktop files
APPLICATIONS_DIR=/usr/share/applications
DESKTOP_DIR=/usr/share/Desktop

mkdir -p "${DESKTOP_DIR}"
# set the Desktop dir to something in base
echo 'XDG_DESKTOP_DIR="${DESKTOP_DIR}"' > /etc/xdg/user-dirs.defaults
for desktop_file_path in ${REPO_DIR}/Desktop/*.desktop; do
    cp "${desktop_file_path}" "${APPLICATIONS_DIR}/."

    # Symlink application to desktop and set execute permission so xfce (desktop) doesn't complain
    desktop_file_name="$(basename ${desktop_file_path})"
    # Set execute permissions on the copied .desktop file
    chmod +x "${APPLICATIONS_DIR}/${desktop_file_name}"
    ln -sf "${APPLICATIONS_DIR}/${desktop_file_name}" "${DESKTOP_DIR}/${desktop_file_name}"
done
