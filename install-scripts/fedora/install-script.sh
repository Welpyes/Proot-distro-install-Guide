#!/data/data/com.termux/files/usr/bin/bash

# Repo confirmation
termux-change-repo
clear

# Prompt the user to enter their username
echo "NOTE: The script will ask for your username again later in the install"
read -p "Please enter your username: " username
echo "Initiating install script..."
sleep 5


# Username variable
username="$username "

# Define the file where you want to place the username
file="fedora.sh"

# Ask if the user wants to install packages
read -p "Do you want to install fedora and necessary packages? (y/n): " install_packages

if [ "$install_packages" = "y" ]; then
    # List of packages to be installed
    packages="proot-distro pulseaudio termux-x11-nightly"  

    # Install the packages
    pkg install root-repo x11-repo -y
    pkg upgrade -y
    pkg install ${packages} -y && curl -o fedora.sh https://raw.githubusercontent.com/Welpyes/Proot-distro-install-Guide/refs/heads/main/install-scripts/fedora/fedora.sh
    pd i fedora

    echo "Packages have been installed."
elif [ "$install_packages" = "n" ]; then
    echo "Installation skipped. Exiting script."
    exit 0
else
    echo "Invalid option. Exiting script."
    exit 1
fi

# Create a temporary file
tmpfile=$(mktemp)

# Insert the username with extra space at line 16, column 132
awk -v username="$username" '{
    if (NR == 16) {
        printf "%s%-*s%s\n", substr($0, 1, 131), 1, username, substr($0, 133)
    } else {
        print $0
    }
}' "$file" > "$tmpfile" && mv "$tmpfile" "$file"

# Fedora Auto setup
proot-distro login fedora --shared-tmp -- /bin/bash -c 'dnf upgrade -y && dnf update -y && exit'

sleep 3
clear

proot-distro login fedora --shared-tmp -- /bin/bash -c 'curl -o account-creation.sh https://raw.githubusercontent.com/Welpyes/Proot-distro-install-Guide/refs/heads/main/install-scripts/fedora/account-creation.sh && bash account-creation.sh && exit'

proot-distro login fedora --shared-tmp -- /bin/bash -c 'curl -o packages.sh https://raw.githubusercontent.com/Welpyes/Proot-distro-install-Guide/refs/heads/main/install-scripts/fedora/packages.sh && bash packages.sh && exit'

proot-distro login fedora --shared-tmp -- /bin/bash -c 'rpm -e xfce-polkit --nodeps'


echo "Fedora linux has been installed to launch type 'bash fedora.sh'"
