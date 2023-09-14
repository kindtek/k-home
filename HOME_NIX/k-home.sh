#!/bin/bash
timestamp=$(date -d "today" +"%Y%m%d%H%M%S")
filename=k-home-nix_$timestamp
nix_user=$(whoami)
if [ "$nix_user" = 'root' ]; then
    khome_user='-r00t'
elif [ "$nix_user" = 'dvl' ]; then
    khome_user='-devel'
else
    khome_user='-angel'
fi
sudo apt-get update --fix-missing -yqq && sudo apt-get install -f && sudo apt-get upgrade -yqq && \
sudo apt-get install --no-install-recommends -y ca-certificates curl lsb-release gpg && \
sudo mkdir -pv /etc/apt/keyrings && \
[ -e "/usr/share/keyrings/docker-archive-keyring.gpg" ] || sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null && \
yes "y" | echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update --fix-missing -yqq && sudo apt-get install -f && sudo apt-get upgrade -yqq && \
sudo apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gnupg
sudo service docker start
[ -f .bashrc ] && cp -fv .bashrc .bashrc.old
# log save location 
mkdir -p logs
tee "logs/$filename.sh" >/dev/null <<'TXT'
#!/bin/bash
set -x

nix_user=$(whoami)
if [ "$nix_user" = "r00t" ]; then
    docker_service=k-home-nix-r00t
elif [ "$nix_user" = "dvl" ]; then
    docker_service=k-home-nix-devel
else
    docker_service=k-home-nix-angel
fi

#               _________________________________________________                 #
#                |||| |           Executing ...           | ||||                  #
#              ---------------------------------------------------                #
#
                    docker compose \
                    -f $HOME/dvlw/dvlp/docker/kali/docker-compose.yaml \
                    build ${docker_service} --no-cache && \
                    docker compose cp ${docker_service}:/ . \
                    2>&1 || exit<<'scratchpad'
scratchpad
# 
#                -----------------------------------------------                   #
#               |||||||||||||||||||||||||||||||||||||||||||||||||                  #
#              ___________________________________________________                 #
TXT

# copy the command to the log first
eval cat "logs/$filename.sh" 2>&1 | tee --append "logs/$filename.log" && \
# execute .sh file && log all output
bash "logs/${filename}.sh"  2>&1 | tee --append "logs/${filename}.log" 
# owner/group perms
chown -R "$(id -un):$(id -Gn | grep -o --color=never '^\w*\b')" ./*.sh
sudo chmod +x k-home.sh start-kde.sh start-kex.sh setup.sh reclone-gh.sh 