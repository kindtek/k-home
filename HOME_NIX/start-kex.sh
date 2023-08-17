#!/bin/bash
win_user=${1:-'no-user-selectedlkadjfasdf'}
port_num=${2:-3390}

while [ ! -d "/mnt/c/users/$win_user" ]; do
    echo " 


    save connection to which Windows home directory?

        C:\\users\\__________\\Kex-GUI.rdp 

        choose from:
    "
    ls -da /mnt/c/users/*/ | tail -n +4 | sed -r -e 's/^\/mnt\/c\/users\/([ A-Za-z0-9]*)*\/+$/\t\1/g'
    read -r -p "
" win_user
done
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

if [ ! -f "/mnt/c/users/$win_user/KEX-GUI.rdp" ]; then
    sudo cp /mnt/data/HOME_WIN/KEX-GUI.rdp /mnt/c/users/$win_user/KEX-GUI.rdp
fi
"$(/etc/init.d/xrdp stop && /etc/init.d/xrdp start && /etc/init.d/xrdp restart)" || \
sudo rm -rf /var/lib/apt/lists && \
sudo rm -rf /var/cache/apt/archives/*.deb && \
sudo apt update -y && sudo apt upgrade -y && sudo apt-get --with-new-pkgs upgrade -y && \
sudo apt install -y powershell virtualbox vlc x11-apps powershell xrdp xfce4 xfce4-goodies libdvd-pkg lightdm kali-defaults kali-root-login desktop-base kali-win-kex && \
sudo dpkg-reconfigure libdvd-pkg && \
sudo rm -rf /var/lib/apt/lists && \
sudo rm -rf /var/cache/apt/archives/*.deb && \
sudo apt update -yq && sudo apt upgrade -yq && sudo apt-get --with-new-pkgs upgrade -yq && \
sudo kill "$(sudo lsof -t /tmp/.X11-unix)" || sudo rm -rf /tmp/.X11-unix && \
"$(/etc/init.d/xrdp stop && /etc/init.d/xrdp start && /etc/init.d/xrdp restart)"

pwsh -Command /mnt/c/Windows/system32/mstsc.exe /mnt/c/users/"$win_user"/KEX-GUI.rdp /v:localhost:"$port_num" /admin /f /multimon || echo '
oops. no gui

 ¯\_(ツ)_/¯
'

kex --win --start-client --sound
# stop: 
# kex --win --stop
# fix perms
# sudo chmod 1777 /tmp/.X11-unix
# reset
# sudo mount -o remount,rw /tmp/.X11-unix
# sudo kill "$(lsof -t /tmp/.X11-unix)" && sudo rm -rf /tmp/.X11-unix/; lsof /tmp/.X11-unix
# ln -sf /mnt/wslg/.X11-unix/X0 /tmp/.X11-unix/
# sudo umount /tmp/.X11-unix
# sudo apt remove -y kali-win-kex && sudo apt install -y kali-win-kex
