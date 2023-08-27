#!/bin/bash
if [ "$1" != "" ]; then
    sudo apt-get install -yq git
else
    sudo apt-get install -y git
fi
dvlw_owner=kindtek
dvlw_fullname=devels-workshop
dvlw_name=dvlw
dvlw_branch=main
dvlw_path=$HOME/$dvlw_name
dvlp_name=dvlp
dvlp_path=$dvlw_path/$dvlp_name
phell_name=powerhell
phell_path=$dvlw_path/$phell_name
dadv_name=dvl-adv
dadv_path=$dvlw_path/$dadv_name
mnt_name=mnt
mnt_path=$dvlp_path/$mnt_name
kernels_name=kernels
kernels_path=$dvlp_path/$kernels_name
# echo "synchronizing $dvlw_path with https://github.com/$dvlw_owner/$dvlw_fullname repo ..." -ForegroundColor DarkCyan
# write-host "testing path $dvlw_path/.git" 
if [ -e "$dvlw_path/.git" ]; then 
    git -C "$dvlw_path" pull --progress
else
    git clone https://github.com/$dvlw_owner/$dvlw_fullname --single-branch --branch $dvlw_branch --filter=blob:limit=13k --progress -- "$dvlw_path"
fi
orig_path="$(pwd)"
cd "$dvlw_path" || exit
if [ -e "$dvlp_path/.git" ]; then
    git submodule update --remote --progress -- $dvlp_name || cd "$dvlp_path" && git reset --hard && cd .. && git submodule update --remote --progress -- $dvlp_name 
else
    git submodule update --init --remote --progress -- $dvlp_name
fi
if [ -e "$dadv_path/.git" ]; then
    git submodule update --remote --progress -- $dadv_name || cd "$dadv_path" && git reset --hard && git reset --hard && cd .. && git submodule update --remote --progress -- $dadv_name
else
    git submodule update --init --remote --progress -- $dadv_name
fi
if [ -e "$phell_path/.git" ]; then
    git submodule update --remote --progress -- $phell_name || cd "$phell_path" && git reset --hard && cd .. && git submodule update --remote --progress -- $phell_name
else
    git submodule update --init --remote --progress -- $phell_name
fi
cd "$dvlp_path" || exit
if [ -e "$mnt_path/.git" ]; then
    git submodule update --remote --progress -- $mnt_name || cd "$phell_path" && git reset --hard && cd .. && git submodule update --remote --progress -- $mnt_name
else
    git submodule update --init --remote --progress -- $mnt_name
fi
if [ -e "$kernels_path/.git" ]; then
    git submodule update --remote --progress -- $kernels_name || cd "$kernels_path" && git reset --hard && cd .. && git submodule update --remote --progress -- $kernels_name
else
    git submodule update --init --remote --progress -- $kernels_name
fi

cd "$orig_path" && exit
# if [ "$1" = "force" ]; then
#     reclone=""
#     sudo apt-get install -yq git
# else
#     sudo apt-get install -y git

#     echo "

#     WARNING!

#         Any changes you made in $HOME/dvlw are about to be erased.

#         continue or exit?"
#     read -r -p "
#     (continue)
#     " reclone
# fi


# if [ "$reclone" = "" ]; then
#     sudo rm -rf dvlw/* || echo "could not remove dvlw directory .."
#     sudo rm -rf dvlw/.* || echo "could not remove git server .."
# fi

# repo_owner=kindtek && \
# repo_name=devels-workshop && \
# repo_url=https://github.com/${repo_owner}/${repo_name} && \
# repo_path=dvlw && \
# repo_branch=main && \
# echo repo_owner: $repo_owner && \
# echo repo_name: "$repo_name" && \
# echo repo_url: "$repo_url" && \
# echo repo_path: "$repo_path" && \
# echo repo_branch: "$repo_branch" && \
# git clone "$repo_url" --single-branch --branch "$repo_branch" --filter=blob:limit=13k --progress -- "$repo_path" && \
# cd dvlw && \
# git submodule update --init --remote --filter=blob:limit=13k --progress -- dvlp dvl-adv powerhell && \
# cd dvlp && \
# git submodule update --init --progress --filter=blob:limit=20m -- kernels mnt && \
# chmod -R 1770 mnt/HOME_NIX && \
# chmod -R 1770 mnt/bak 
