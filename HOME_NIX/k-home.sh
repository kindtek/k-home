#!/bin/bash
timestamp=$(date -d "today" +"%Y%m%d%H%M%S")
filename=k-home-nix_$timestamp
sudo service docker start
# log save location 
mkdir -p logs
tee "logs/$filename.sh" >/dev/null <<'TXT'
#!/bin/bash
set -x

#               _________________________________________________                 #
#                |||| |           Executing ...           | ||||                  #
#              ---------------------------------------------------                #
#
                    docker buildx build ${build_cache} \
                    --file dvlw/dvlp/docker/kali/Dockerfile \
                    --target dvlp_k-home-nix \
                    --output type=local,dest=. \
                    --no-cache-filter=dvlp_repo-build \
                    --progress=plain \
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
# owner/group perms
chown -R "$(id -un):$(id -Gn | grep -o --color=never '^\w*\b')" ./*.sh
sudo chmod +x k-home.sh start-kde.sh start-kex.sh setup.sh reclone-gh.sh 