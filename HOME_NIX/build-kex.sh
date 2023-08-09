#!/bin/bash
if [ ! -d "$HOME/dvlw/dvlp/mnt/etc" ]; then
    ./reclone-gh.sh
fi
echo "
pull k-home files from repo to /etc?"
read -r -p "
(yes)
" update_home
if [ "${update_home,,}" = "" ] || [ "${update_home,,}" = "y" ] || [ "${update_home,,}" = "yes" ]; then
    sudo cp -rfv "$HOME/dvlw/dvlp/mnt/etc/" "/"
fi
sudo rm -rf /var/lib/apt/lists && \
sudo rm -rf /var/cache/apt/archives/*.deb && \
sudo apt update -y && sudo apt upgrade && sudo apt-get --with-new-pkgs upgrade && sudo dpkg-reconfigure libdvd-pkg && \
sudo apt install -y powershell virtualbox vlc x11-apps xrdp xfce4 xfce4-goodies lightdm kali-defaults kali-root-login desktop-base kali-win-kex
