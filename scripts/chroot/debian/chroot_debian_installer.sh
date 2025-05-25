#!/bin/sh

CHROOT_NAME=""  # allows to set a custom part in all names that have to be unique. Allows setting up multiple chroots in parallel. Can be left empty as long as this script is only used once.
DOWNLOAD_FILE_NAME="debian-trixie-arm64.tar.xz"
DEBIANPATH="/data/local/tmp/chrootDebian$CHROOT_NAME"
SYSTEM_CMD_START_CHROOT="start_debian$CHROOT_NAME"

# Function to show farewell message
goodbye() {
    echo -e "\e[1;31m[!] Something went wrong. Exiting...\e[0m"
    exit 1
}

# Function to show progress message
progress() {
    echo -e "\e[1;36m[+] $1\e[0m"
}

# Function to show success message
success() {
    echo -e "\e[1;32m[✓] $1\e[0m"
}

# Function to download file
download_file() {
    progress "Downloading file..."
    if [ -e "$1/$2" ]; then
        echo -e "\e[1;33m[!] File already exists: $2\e[0m"
        echo -e "\e[1;33m[!] Skipping download...\e[0m"
    else
        wget -O "$1/$2" "$3"
        if [ $? -eq 0 ]; then
            success "File downloaded successfully: $2"
        else
            echo -e "\e[1;31m[!] Error downloading file: $2. Exiting...\e[0m"
            goodbye
        fi
    fi
}

# Function to extract file
extract_file() {
    progress "Extracting file..."
    if [ -d "$1/debian12-arm64" ]; then
        echo -e "\e[1;33m[!] Directory already exists: $1/debian12-arm64\e[0m"
        echo -e "\e[1;33m[!] Skipping extraction...\e[0m"
    else
        tar xpvf "$1/$DOWNLOAD_FILE_NAME" -C "$1" --numeric-owner >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            success "File extracted successfully: $1/debian12-arm64"
        else
            echo -e "\e[1;31m[!] Error extracting file. Exiting...\e[0m"
            goodbye
        fi
    fi
}

download_start_script() {
    progress "Downloading script..."
    if [ -e "/data/local/tmp/start_debian$CHROOT_NAME.sh" ]; then
        echo -e "\e[1;33m[!] Script already exists: /data/local/tmp/start_debian$CHROOT_NAME.sh\e[0m"
        echo -e "\e[1;33m[!] Skipping download...\e[0m"
    else
        wget -O "/data/local/tmp/start_debian$CHROOT_NAME.sh" "https://raw.githubusercontent.com/Glutamat42/Termux-Desktops/main/scripts/chroot/debian/start_debian.sh"
        if [ $? -eq 0 ]; then
            success "Script downloaded successfully: /data/local/tmp/start_debian$CHROOT_NAME.sh"
            progress "Setting script permissions..."
            chmod +x "/data/local/tmp/start_debian$CHROOT_NAME.sh"
            success "Script permissions set"
        else
            echo -e "\e[1;31m[!] Error downloading script. Exiting...\e[0m"
            goodbye
        fi
    fi
}

# Function to configure Debian chroot environment
configure_debian_chroot() {
    progress "Configuring Debian chroot environment..."

    # Check if DEBIANPATH directory exists
    if [ ! -d "$DEBIANPATH" ]; then
        mkdir -p "$DEBIANPATH"
        if [ $? -eq 0 ]; then
            success "Created directory: $DEBIANPATH"
        else
            echo -e "\e[1;31m[!] Error creating directory: $DEBIANPATH. Exiting...\e[0m"
            goodbye
        fi
    fi

    busybox mount -o remount,dev,suid /data
    busybox mount --bind /dev $DEBIANPATH/dev
    busybox mount --bind /sys $DEBIANPATH/sys
    busybox mount --bind /proc $DEBIANPATH/proc
    busybox mount -t devpts devpts $DEBIANPATH/dev/pts

    mkdir $DEBIANPATH/dev/shm
    busybox mount -t tmpfs -o size=256M tmpfs $DEBIANPATH/dev/shm

    mkdir $DEBIANPATH/sdcard
    busybox mount --bind /sdcard $DEBIANPATH/sdcard
    
    busybox chroot $DEBIANPATH /bin/su - root -c 'apt update -y && apt upgrade -y'
    busybox chroot $DEBIANPATH /bin/su - root -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf; \
    echo "127.0.0.1 localhost" > /etc/hosts; \
    groupadd -g 3003 aid_inet; \
    groupadd -g 3004 aid_net_raw; \
    groupadd -g 1003 aid_graphics; \
    groupadd -g 1077 external_storage; \
    groupadd -g 1023 media_rw; \
    usermod -g 3003 -G 3003,3004 -a _apt; \
    usermod -G 3003 -a root; \
    apt update; \
    apt upgrade; \
    apt install nano vim net-tools sudo git; \
    echo "Debian chroot environment configured"'

    if [ $? -eq 0 ]; then
        success "Debian chroot environment configured"
    else
        echo -e "\e[1;31m[!] Error configuring Debian chroot environment. Exiting...\e[0m"
        goodbye
    fi

    # Prompt for username
    progress "Setting up user account..."
    echo -n "Enter username for Debian chroot environment: "
    read USERNAME

    # Add the user
    busybox chroot $DEBIANPATH /bin/su - root -c "adduser $USERNAME"

    # Add user to sudoers
    progress "Configuring sudo permissions..."
    busybox chroot $DEBIANPATH /bin/su - root -c "echo '$USERNAME ALL=(ALL:ALL) ALL' >> /etc/sudoers"

    progress "Configuring user permissions (groups)"
    busybox chroot $DEBIANPATH /bin/su - root -c "usermod -aG aid_inet external_storage media_rw $USERNAME"

    success "User account set up and sudo permissions configured"

    # Prompt for desktop environment
    progress "Select a desktop environment to install:"
    echo "1. XFCE4"
    echo "2. openbox"
    echo -n "Enter your choice (1-4): "
    read DE_OPTION

    # Install selected desktop environment
    case $DE_OPTION in
        1)
            install_xfce4
            ;;
        2)
            install_openbox
            ;;
        *)
            echo -e "\e[1;31m[!] Invalid option. Exiting...\e[0m"
            goodbye
            ;;
    esac
}

# Function to install XFCE4 desktop environment
install_xfce4() {
    progress "Installing XFCE4..."
    busybox chroot $DEBIANPATH /bin/su - root -c 'apt update -y && apt install dbus-x11 xfce4 xfce4-terminal -y'
    START_DESKTOP_CMD="startxfce4"
}

# Function to install openbox window manager
install_openbox() {
    progress "Installing KDE..."
    busybox chroot $DEBIANPATH /bin/su - root -c 'apt update -y && apt install dbus-x11 xorg openbox -y'
    START_DESKTOP_CMD="startx"
}

create_termux_script() {
    echo "#!/bin/sh
    /data/local/tmp/start_debian$CHROOT_NAME.sh" | sudo tee /data/data/com.termux/files/usr/bin/$SYSTEM_CMD_START_CHROOT > /dev/null
    sudo chmod +x /data/data/com.termux/files/usr/bin/$SYSTEM_CMD_START_CHROOT
}


modify_startfile_with_username() {
    success "Set start_debian.sh file with user name..."
    sed -i "s/REPLACEME_CHROOT_USERNAME/$USERNAME/g" "$DEBIANPATH/../start_debian$CHROOT_NAME.sh"
    sed -i "s/REPLACEME_START_DESKTOP_CMD/$START_DESKTOP_CMD/g" "$DEBIANPATH/../start_debian$CHROOT_NAME.sh"
    sed -i "s/REPLACEME_DEBIANPATH/$DEBIANPATH/g" "$DEBIANPATH/../start_debian$CHROOT_NAME.sh"
}

print_finish_msg() {
    success "Setup finished. Run 'hash -r' once and then start chroot with $SYSTEM_CMD_START_CHROOT"
}

# Main function
main() {
    if [ "$(whoami)" != "root" ]; then
        echo -e "\e[1;31m[!] This script must be run as root. Exiting...\e[0m"
        goodbye
    else
        download_dir="$DEBIANPATH"
        if [ ! -d "$download_dir" ]; then
            mkdir -p "$download_dir"
            success "Created directory: $download_dir"
        fi
        download_file "$download_dir" "$DOWNLOAD_FILE_NAME" "https://github.com/Glutamat42/Termux-Desktops/releases/download/debian-trixie-rootfs/debian-trixie-arm64.tar.xz"
        extract_file "$download_dir"
        rm "$download_dir/$DOWNLOAD_FILE_NAME"  # remove downloaded file, not needed anymore
        download_start_script "$download_dir"
        configure_debian_chroot
        modify_startfile_with_username
        print_finish_msg
    fi
}

# Call the main function
echo -e "\e[32m"
cat << "EOF"
___  ____ ____ _ ___  _  _ ____ ____ ___ ____ ____    ____ _  _ ____ ____ ____ ___ 
|  \ |__/ |  | | |  \ |\/| |__| [__   |  |___ |__/    |    |__| |__/ |  | |  |  |  
|__/ |  \ |__| | |__/ |  | |  | ___]  |  |___ |  \    |___ |  | |  \ |__| |__|  |  
                                                                                   
EOF
echo -e "\e[0m"

main
