#!/bin/bash
timestamp=$(date -d "today" +"%Y%m%d%H%M%S")
filename=k-home-win_${timestamp}
sudo service docker start
# log save location 
mkdir -p logs
mkdir -p repos/kindtek/dvlw
tee "logs/$filename.sh" >/dev/null <<'TXT'
#!/bin/bash
set -x

docker_service=build-k-home-win

#               _________________________________________________                 #
#                |||| |           Executing ...           | ||||                  #
#              ---------------------------------------------------                #
#
                    docker compose \
                    -f $_WIN_USER_HOME/dvlw/dvlp/docker/kali/docker-compose.yaml \
                    build vol-kernel --no-cache && \
                    docker compose \
                    -f $_WIN_USER_HOME/dvlw/dvlp/docker/kali/docker-compose.yaml \
                    up vols-kernel --detach && \
                    docker compose \
                    -f $_WIN_USER_HOME/dvlw/dvlp/docker/kali/docker-compose.yaml \
                    cp vols-kernel:/hal/dvlw/dvlp/mnt/HOME_WIN/ . \
                    docker compose \
                    -f $_WIN_USER_HOME/dvlw/dvlp/docker/kali/docker-compose.yaml \
                    cp vols-kernel:/hal/dvlw/ repos/kindtek/dvlw/ \
                    2>&1 || exit<<'scratchpad'
                    . 2>&1 || exit<<'scratchpad'
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