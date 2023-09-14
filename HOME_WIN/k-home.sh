#!/bin/bash
timestamp=$(date -d "today" +"%Y%m%d%H%M%S")
filename=k-home-win_${timestamp}
sudo service docker start
# log save location 
mkdir -p logs
tee "logs/$filename.sh" >/dev/null <<'TXT'
#!/bin/bash
set -x

docker_service=k-home-win

#               _________________________________________________                 #
#                |||| |           Executing ...           | ||||                  #
#              ---------------------------------------------------                #
#
                    docker compose \
                    -f $WIN_USER_HOME/dvlw/dvlp/docker/kali/docker-compose.yaml \
                    build ${docker_service} --no-cache && \
                    docker compose cp ${docker_service}:/ . \
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