#!/bin/bash
win_user=$1
ssh_dir_default=$HOME/.ssh
confirm_regen="r"
warning=""

orig_win_user=$win_user
orig_pwd=$(pwd)

# update install apt-utils dialog kali-linux-headless upgrade
echo "
initialize/update dependencies?"
    read -r -p "
(yes)
" update_upgrade
if [ "${update_upgrade,,}" != "n" ] && [ "${update_upgrade,,}" != "n" ]; then
    sudo apt -y update && sudo apt -y install apt-utils dialog kali-linux-headless && sudo apt -y upgrade 
fi

# cdir install
echo "
install cdir?"
read -r -p "
(no)
" install_cdir
if [ "${install_cdir,,}"  = "y" ] || [ "${install_cdir,,}" = "yes" ]; then
    sudo apt-get update -y && sudo apt-get autoremove -y && \
    sudo apt-get install --no-install-recommends -y jq python3-pip python3-venv && \
    pip3 install pip --upgrade --no-warn-script-location --no-deps && \
    pip3 install cdir --user
fi

# k-home
echo "
pull k-home files from repo to $HOME?"
read -r -p "
(no)
" update_home
if [ "${update_home,,}"  = "y" ] || [ "${update_home,,}" = "yes" ]; then
    ./k-home.sh "$WIN_USER"
fi

# ssh gen
if [ -f "$HOME/.ssh/known_hosts" ]; then
    echo "
regenerate ssh keys?"
    read -r -p "
(no)
" regen_ssh
    if [ "${regen_ssh}" = "" ] || [ "${regen_ssh,,}" = "n" ] || [ "${regen_ssh,,}" = "no" ]; then
        confirm_regen=""
    fi
fi

if [ "$confirm_regen" != "" ]; then 
    while [ "${confirm_regen,,}" = "r" ] || [ "${confirm_regen,,}" = "retry" ]; do
        clear -x
        echo "


     -------------------------------------------------------
    |    ENTER CREDENTIAL INFO                              |
     -------------------------------------------------------"
        while [ -z "$git_uname" ]; do
            read -r -p "
        github username: 
            " git_uname
        done
        git_uname=$git_uname@github.com
        while [ -z "$git_email" ]; do
            read -r -p "
        email address: 
            " git_email
        done
        if [ -z "$ssh_dir" ]; then
            read -r -p "
        press ENTER to use default save location (${ssh_dir:-$ssh_dir_default})
        OR enter a custom save directory:
            " ssh_dir
            ssh_dir=${ssh_dir:-$ssh_dir_default}
        fi

        test_dir="$ssh_dir/testing_permissions_123"
        #test permissions with mkdir
        echo "
    testing write access in $ssh_dir ...
    attempting to create new directory in $ssh_dir ...
        "
        if ! mkdir -pv "$test_dir"; then
            warning+="

        WARNING: 
        insufficient write privileges for $ssh_dir
    
"
        fi 
        if [ -r "$ssh_dir/id_ed25519" ] || [ -r "$ssh_dir/id_ed25519" ]; then
            warning+="

            !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!

                keys EXIST and may be LOST
            
            !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!

    an attempt will be made to rename the directory to $ssh_dir.old
"
        fi
        # cleanup test_dir
        rmdir -v "$test_dir"

        max_padding=48
        git_uname_len=${#git_uname}
        uname_padding_ws_count=$((max_padding - git_uname_len))
        uname_padding=""
        if [ "$uname_padding_ws_count" -lt 0 ]; then 
            uname_padding_ws_count=0
            uname_padding=""
        else
            for ((i=0;i<uname_padding_ws_count;i++))
            do
                uname_padding+=" "
            done
            uname_padding+="|"
        fi

        # echo uname_padding_ws_count=$uname_padding_ws_count

        git_email_len=${#git_email}
        email_padding_ws_count=$((max_padding - git_email_len))
        email_padding=""
        if [ "$email_padding_ws_count" -lt 0 ]; then 
            email_padding_ws_count=0
            email_padding=""
        else
            for ((i=0;i<email_padding_ws_count;i++))
            do
                email_padding+=" "
            done
            email_padding+="|"
        fi

        # echo email_padding_ws_count=$email_padding_ws_count
    
        ssh_dir_len=${#ssh_dir}
        ssh_dir_padding_ws_count=$((max_padding - ssh_dir_len))  
        ssh_dir_padding=""
        if [ "$ssh_dir_padding_ws_count" -lt 0 ]; then
            ssh_dir_padding_ws_count=0
            ssh_dir_padding=""
        else
            for ((i=0;i<ssh_dir_padding_ws_count;i++))
            do
                ssh_dir_padding+=" "
            done
            ssh_dir_padding+="|"
        fi

    # echo ssh_dir_padding_ws_count=$ssh_dir_padding_ws_count

        clear -x
        read -r -p "


     -------------------------------------------------------
    |    CONFIRM CREDENTIAL INFO                            |
     -------------------------------------------------------
    |                                                       |
    |   github username:                                    |
    |       $git_uname$uname_padding
    |                                                       |
    |   email address:                                      |
    |       $git_email$email_padding
    |                                                       |
    |   save location:                                      |
    |       $ssh_dir$ssh_dir_padding
    |                                                       |
    |_______________________________________________________|
        $warning

    press ENTER to confirm and generate credentials

    [r]etry / e[x]it / (continue) " confirm_regen
        if [ "$confirm_regen" == "continue" ] || [ "$confirm_regen" == "" ]; then break; fi
        if [ "$confirm_regen" == "exit" ] || [ "$confirm_regen" == "x" ]; then exit; fi
        if [ "${confirm_regen,,}" != "r" ] && [ "${confirm_regen,,}" != "retry" ]; then exit; fi
        if [ "${confirm_regen,,}" == "r" ] || [ "${confirm_regen,,}" == "retry" ]; then 
            echo "
        retrying ... ";
            unset ssh_dir git_uname git_email warning;
        fi
    done
    echo "
    -- use CTRL + C to cancel --
    "
    sleep 3

    if [ -r "$ssh_dir/id_ed25519" ] || [ -r "$ssh_dir/id_ed25519" ]; then
        mv -bv "$ssh_dir" "$ssh_dir.old"
    fi

    echo "generating keys and saving to $ssh_dir"
    # if [ -d $ssh_dir ]; then echo "----- $ssh_dir directory already exists - remove the directory ( rm -rf $ssh_dir ) and try again -----"; fi;
    # rm -f $ssh_dir/id_ed25519 $ssh_dir/id_ed25519.pub 
    git config --global user.email "$git_email";
    git config --global user.name "$git_uname";
    rm -fv "$ssh_dir/id_ed25519" "$ssh_dir/id_ed25519.pub";
    ssh-keygen -C "$git_uname" -f "$ssh_dir/id_ed25519" -N "" -t ed25519;
    eval "$(ssh-agent -s)";
    ssh-add "$ssh_dir"/id_ed25519;

    # quietly verify host signature before using ssh-key
    host_fingerprint_expected_rsa='github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==';
    host_fingerprint_actually_rsa="$(ssh-keyscan -t rsa github.com)";
    # quietly verify host signature before using ssh-key
    host_fingerprint_expected_ed25519='github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl';
    host_fingerprint_actually_ed25519="$(ssh-keyscan -t ed25519 github.com)";
    # quietly verify host signature before using ssh-key
    host_fingerprint_expected_ecdsa='github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=';
    host_fingerprint_actually_ecdsa="$(ssh-keyscan -t ecdsa github.com)";
    # if verified save - otherwise output error and stop

    matching_prints_rsa=false;
    matching_prints_ed25519=false;
    matching_prints_ecdsa=false;


    if [ "$host_fingerprint_actually_ecdsa" = "$host_fingerprint_expected_ecdsa" ]; then matching_prints_rsa=true; fi;
    if [ "$host_fingerprint_actually_ed25519" = "$host_fingerprint_expected_ed25519" ]; then matching_prints_ed25519=true; fi;
    if [ "$host_fingerprint_actually_ecdsa" = "$host_fingerprint_expected_ecdsa" ]; then matching_prints_ecdsa=true; fi;
    if [ "$matching_prints_rsa" ] && [ "$matching_prints_ed25519" ] && [ "$matching_prints_ecdsa" ]; then
        echo "
    github host confirmed and verified
    "
        if [ -f "$ssh_dir/known_hosts" ]; then ssh-keyscan github.com >> "$ssh_dir/known_hosts"; else ssh-keyscan github.com > "$ssh_dir/known_hosts"; fi;
        else
	        echo '

    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    
';

        if ! [ "$matching_prints_rsa" ]; then printf '\nexpected RSA:\t%s\nactual RSA:\t%s' "$host_fingerprint_expected_rsa" "$host_fingerprint_actually_rsa";   fi;
        if ! [ "$matching_prints_ed25519" ]; then  printf '\nexpected ED25519:\t%s\nactual ED25519:\t%s' "$host_fingerprint_expected_ed25519" "$host_fingerprint_actually_ed25519";  fi;
        if ! [ "$matching_prints_ecdsa" ]; then  printf '\nexpected ECDSA:\t%s\nactual ECDSA:\t%s' "$host_fingerprint_expected_ecdsa" "$host_fingerprint_actually_ecdsa";  fi;

        echo '

    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    !!!!!!!!! WARNING !!!!!!!!! 
    GH SSH KEYS *NOT* AUTHENTIC 
    !!!!!!!!! WARNING !!!!!!!!! 
    
    
';
        fi
fi

# CUDA install
echo "
install CUDA?"
read -r -p "
(no)
" install_cuda
if [ "${install_cuda,,}"  = "y" ] || [ "${install_cuda,,}" = "yes" ]; then
    sudo apt-get install --no-install-recommends -y nvidia-cuda-toolkit
fi

# enable virtual network
echo "
convert virtual network connection to bridged? (requires elevated access privileges)"
read -r -p "
(no)
" convert_net
if [ "${convert_net,,}"  = "y" ] || [ "${convert_net,,}" = "yes" ]; then
    powershell.exe ./bridge-wsl2-net.ps1 || pwsh ./bridge-wsl2-net.ps1 || echo "
------------------------------- copy_start -------------------------------

" && tail -n +10 bridge-wsl2-net.ps1 && echo "

------------------------------- copy_end ---------------------------------

Ooops ... failed to automatically add WSL firewall rules.
to manually update:

1)  open a windows shell with admin privileges
        
        shortcut: 
            - [WIN + X] then [a]    (opens admin window)
            - [<-] then [ENTER]     (confirm elevated access privileges)


2)  copypasta (copy code between copy_start and copy_end and paste into terminal)


" && read -r -p "(continue)"
elif [ "${convert_net,,}"  = "revert" ]; then
    powershell.exe ./bridge-wsl2-net.ps1 || pwsh ./bridge-wsl2-net.ps1 || echo "
------------------------------- copy_start -------------------------------

" && echo "#Remove Firewall Exception Rules
Invoke-Expression \"Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock Outbound'\";
Invoke-Expression \"Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock Inbound'\";" && echo "

------------------------------- copy_end ---------------------------------

Ooops ... failed to automatically remove WSL firewall rules.
to manually update:

1)  open a windows shell with admin privileges
        
        shortcut: 
            - [WIN + X] then [a]    (opens admin window)
            - [<-] then [ENTER]     (confirm elevated access privileges)


2)  copypasta (copy code between copy_start and copy_end and paste into terminal)


" && read -r -p "(continue)"
fi

# %USERPROFILE% integration
[ ! -d "/mnt/c/users" ] || cd "/mnt/c/users" || exit
while [ ! -d "$win_user" ]; do
    if [ ! -d "/mnt/c/users" ]; then
        if [ ! -d "/mnt/c/users/$win_user" ]; then
            echo "/mnt/c/users/$win_user is not a directory - skipping prompt for home directory"
        fi
        break;
    fi
    echo " 


integrate windows home directory?

this directory will be used for:
    - WSL configuration management
    - kernel installations
    - sync home directory with repo

    choose from:
    " 
    ls -da /mnt/c/users/*/ | tail -n +4 | sed -r -e 's/^\/mnt\/c\/users\/([ A-Za-z0-9]*)*\/+$/\t\1/g'

    read -r -p "

(skip)  C:\\users\\" win_user
    if [ "$win_user" = "" ]; then
        win_user=$orig_win_user
        break
    fi
    if [ ! -d "/mnt/c/users/$win_user" ]; then
        echo "

        
        
        







C:\\users\\$win_user is not a home directory"
    else
        WIN_USER=$win_user
        WIN_USER_HOME=/mnt/c/users/$win_user
        WIN_USER_KACHE=/mnt/c/users/$win_user/kache
        export WIN_USER
        export WIN_USER_HOME
        export WIN_USER_KACHE
        PATH="$PATH:/mnt/c/users/$WIN_USER/kache"
    fi
done
cd "$orig_pwd" || exit

echo "
build basic kernel for WSL? (ZFS optional)"
read -r -p "
(no)
" install_basic_kernel
if [ "${install_basic_kernel,,}"  = "y" ] || [ "${install_basic_kernel,,}" = "yes" ]; then
    if [ "$(read -r -p '
(install with zfs filesystem)')" = "" ]; then
        sudo bash /hal/dvlw/dvlp/kernels/linux/build-import-kernel.sh "basic" "" "zfs" "$WIN_USER" && \
        sudo bash /hal/dvlw/dvlp/kernels/linux/install-kernel.sh "$WIN_USER" "latest"
    else
        sudo bash /hal/dvlw/dvlp/kernels/linux/build-import-kernel.sh "basic" "" "" "$WIN_USER" && \
        sudo bash /hal/dvlw/dvlp/kernels/linux/install-kernel.sh "$WIN_USER" "latest"
    fi
else
    echo "
    build latest kernel for WSL? (ZFS unavailable)"
    read -r -p "
    (no)
    " install_latest_kernel
    if [ "${install_latest_kernel,,}"  = "y" ] || [ "${install_latest_kernel,,}" = "yes" ]; then
        sudo bash /hal/dvlw/dvlp/kernels/linux/build-import-kernel.sh "latest" "" "" "$WIN_USER" && \
        sudo bash /hal/dvlw/dvlp/kernels/linux/install-kernel.sh "$WIN_USER" "latest"
    else
        echo "
        build stable kernel for WSL? (ZFS unavailable)"
        read -r -p "
        (no)
        " install_stable_kernel
        if [ "${install_stable_kernel,,}"  = "y" ] || [ "${install_stable_kernel,,}" = "yes" ]; then
            sudo bash /hal/dvlw/dvlp/kernels/linux/build-import-kernel.sh "stable" "" "" "$WIN_USER" && \
            sudo bash /hal/dvlw/dvlp/kernels/linux/install-kernel.sh "$WIN_USER" "latest"
        fi
    fi
fi

echo "
build KEX gui?"
read -r -p "
(no)
" build_kex
if [ "${build_kex,,}"  = "y" ] || [ "${build_kex,,}" = "yes" ]; then
    ./start-kex.sh "$WIN_USER"
fi

echo "
build KDE gui?"
read -r -p "
(no)
" build_kde
if [ "${build_kde,,}"  = "y" ] || [ "${build_kde,,}" = "yes" ]; then
    ./start-kde.sh "$WIN_USER"
fi



echo "operation complete ..."


