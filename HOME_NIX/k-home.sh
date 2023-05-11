#!/bin/bash
timestamp=$(date -d "today" +"%Y%m%d%H%M%S")
filename=k-home_$timestamp
win_user=${1}


while [ "$win_user" = "" ] || [ ! -d "/mnt/c/users/$win_user" ]; do
    if [ "$win_user" != "" ]; then
        echo "could not find C:\\users\\$win_user"
    fi

    echo "


    install to which Windows home directory?

        C:\\users\\__________

        choose from:
    " 
    ls -da /mnt/c/users/*/ | tail -n +4 | sed -r -e 's/^\/mnt\/c\/users\/([ A-Za-z0-9]*)*\/+$/\t\1/g'
    read -r -p "
" win_user
done


# log save location 
mkdir -p logs
tee "logs/$filename.sh" >/dev/null <<'TXT'
#!/bin/bash
set -x
win_user=${1}

#               _________________________________________________                 #
#                |||| |           Executing ...           | ||||                  #
#              ---------------------------------------------------                #
#
                    docker buildx build ${build_cache} \
                    --file dvlw/dvlp/docker/kali/Dockerfile \
                    --target dvlp_repo-k-home \
                    --output type=local,dest=. \
                    --build-arg LINUX=y \
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