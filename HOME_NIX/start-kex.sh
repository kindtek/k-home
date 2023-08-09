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
if [ ! -f "/mnt/c/users/$win_user/KEX-GUI.rdp" ]; then
    sudo cp /mnt/data/HOME_WIN/KEX-GUI.rdp /mnt/c/users/$win_user/KEX-GUI.rdp
fi
sudo "$(/etc/init.d/xrdp stop && sudo /etc/init.d/xrdp start && sudo /etc/init.d/xrdp restart)" || sudo kill "$(lsof -t /tmp/.X11-unix)" && sudo rm -rf /tmp/.X11-unix/; 
sudo lsof /tmp/.X11-unix

pwsh -Command /mnt/c/Windows/system32/mstsc.exe /mnt/c/users/"$win_user"/Kex-GUI.rdp /v:localhost:"$port_num" /admin /f /multimon || echo '
oops. no gui

 ¯\_(ツ)_/¯
'

kex --win --start-client --sound
# stop: 
# kex --win --stop
# fix perms
# sudo chmod 1777 /tmp/.X11-unix
# reset
# sudo kill "$(lsof -t /tmp/.X11-unix)" && sudo rm -rf /tmp/.X11-unix/; lsof /tmp/.X11-unix
# sudo apt remove -y kali-win-kex && sudo apt install -y kali-win-kex
