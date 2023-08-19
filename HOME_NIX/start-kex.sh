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
sudo cp -rfv "$HOME/dvlw/dvlp/mnt/etc/" "/"
sudo cp -rfv /mnt/data/HOME_WIN/KEX-GUI.rdp /mnt/c/users/$win_user/KEX-GUI.rdp


kex --win --start-client --sound || sudo rm -rf /var/lib/apt/lists && \
sudo rm -rf /var/cache/apt/archives/*.deb && \
sudo apt-get update -yq && sudo apt-get upgrade -yq && sudo apt-get --with-new-pkgs upgrade -yq && \
sudo apt-get install -yq powershell virtualbox vlc x11-apps powershell xrdp xfce4 xfce4-goodies lightdm kali-defaults kali-root-login desktop-base kali-win-kex || \
( sudo apt-get install -y powershell virtualbox vlc x11-apps powershell xrdp xfce4 xfce4-goodies libdvd-pkg lightdm kali-defaults kali-root-login desktop-base kali-win-kex && \
sudo dpkg-reconfigure libdvd-pkg )
( ( sudo /etc/init.d/xrdp stop && sudo /etc/init.d/xrdp start && sudo /etc/init.d/xrdp restart ) && kex --win --start-client --sound ) || \
( sudo kill "$(sudo lsof -t /tmp/.X11-unix)" || sudo rm -rf /tmp/.X11-unix && kex --win --start-client --sound )
# "$(sudo /etc/init.d/xrdp stop && sudo /etc/init.d/xrdp start && sudo /etc/init.d/xrdp restart)"
# Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "$env:userprofile\Documents\RDP-Name.rdp"
# pwsh -Command /mnt/c/Windows/system32/mstsc.exe /mnt/c/users/"$win_user"/KEX-GUI.rdp /v:localhost:"$port_num" /admin /f /multimon || echo '
# pwsh -command "/mnt/c/windows/system32/mstsc.exe /mnt/c/users/"$win_user"/KEX-gui.rdp /v:localhost:3390 /admin /f /multimon"
# pwsh -command "/mnt/c/windows/system32/mstsc.exe /mnt/c/users/n8kin/KEX-gui.rdp"
# oops. no gui

#  ¯\_(ツ)_/¯
# '
# stop: 
# kex --win --stop
# sudo apt install -y tigervnc-tools
# fix perms
# sudo chmod 1777 /tmp/.X11-unix
# reset
# sudo mount -o remount,rw /tmp/.X11-unix
# sudo kill "$(lsof -t /tmp/.X11-unix)" && sudo rm -rf /tmp/.X11-unix/; lsof /tmp/.X11-unix
# ln -sf /mnt/wslg/.X11-unix/X0 /tmp/.X11-unix/
# sudo umount /tmp/.X11-unix
# sudo apt remove -y kali-win-kex && sudo apt install -y kali-win-kex
