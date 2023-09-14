#!/bin/bash
timestamp=$(date -d "today" +"%Y%m%d%H%M%S")
filename=k-home-win_${timestamp}
sudo service docker start
# log save location 
mkdir -p logs
docker_service=k-home-win
tee "logs/$filename.sh" >/dev/null <<'TXT'
#!/bin/bash
set -x

#               _________________________________________________                 #
#                |||| |           Executing ...           | ||||                  #
#              ---------------------------------------------------                #
#
                    docker compose up --build ${docker_service} --detach && \
                    docker compose cp ${docker_service}:\ . \
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