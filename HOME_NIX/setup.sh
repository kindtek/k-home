#!/bin/bash
orig_win_user=$WIN_USER
WIN_USER=$1
ssh_dir_default=$HOME/.ssh
confirm_regen="r"
warning=""
orig_pwd=$(pwd)
nix_user=$(whoami)

if [ "$WIN_USER" != "$orig_win_user" ] && [ "$WIN_USER" != "" ] && [ "$orig_win_user" != "" ] && [ -d "/mnt/c/$WIN_USER" ]; then
        WIN_USER_HOME=/mnt/c/users/$WIN_USER
        WIN_USER_KACHE=/mnt/c/users/$WIN_USER/kache
        export WIN_USER
        export WIN_USER_HOME
        export WIN_USER_KACHE
        PATH="$PATH:/mnt/c/users/$WIN_USER/kache"
fi
if [ "$WIN_USER_HOME" = "" ]; then
        WIN_USER_HOME=/mnt/c/users/$WIN_USER
        WIN_USER_KACHE=/mnt/c/users/$WIN_USER/kache
        export WIN_USER
        export WIN_USER_HOME
        export WIN_USER_KACHE
        PATH="$PATH:/mnt/c/users/$WIN_USER/kache"
fi
# %USERPROFILE% integration
while [ ! -d "/mnt/c/users/$WIN_USER" ]; do
    [ ! -d "/mnt/c/users" ] || cd "/mnt/c/users" || break
    if [ ! -d "/mnt/c/users" ]; then
        if [ ! -d "/mnt/c/users/$WIN_USER" ]; then
            echo "/mnt/c/users/$WIN_USER is not a directory - skipping prompt for home directory"
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

(skip)  C:\\users\\
" WIN_USER
    if [ "$WIN_USER" = "" ]; then
        WIN_USER=$orig_win_user
        break
    fi
    if [ ! -d "$WIN_USER_KACHE" ]; then
        echo "

        
        
        







C:\\users\\$WIN_USER is not a home directory"
    else
        echo "setting linux environment variables for $WIN_USER"
        WIN_USER_HOME=/mnt/c/users/$WIN_USER
        WIN_USER_KACHE=/mnt/c/users/$WIN_USER/kache
        export WIN_USER
        export WIN_USER_HOME
        export WIN_USER_KACHE
        PATH="$PATH:$WIN_USER_KACHE"
    fi
done

if ls /kache/*.tar.gz 1> /dev/null 2>&1; then
    kernel_tar_path=$(ls -txr1 /kache/*.tar.gz  | tail --lines=1)
    kernel_tar_file=$(echo "$kernel_tar_path") 
    kernel_tar_filename=${kernel_tar_file%.*}
    kernel_tar_filename=${kernel_tar_filename%.*}
    echo "
    import ${kernel_tar_filename} into WSL?"
    read -r -p "
    (yes)
    " import_kernel
    if [ "${import_kernel,,}" = "y" ] || [ "${import_kernel,,}" = "yes" ] || [ "${import_kernel,,}" = "" ]; then
        
        sudo mkdir -p "$WIN_USER_HOME/kache"
        sudo chown -R "${_AGL:agl}:halo" "$WIN_USER_HOME/kache"
        bash "$HOME/k-home.sh" && \
        sudo cp -rfv "$kernel_tar_path" "/mnt/c/users/$WIN_USER$kernel_tar_path" && \
        cd "$WIN_USER_HOME/kache" && \
        sudo tar --overwrite -xzvf "${kernel_tar_filename}.tar.gz" && \
        # bash update-initramfs -u -k !wsl_default_kernel! 
        sudo apt-get -yq install powershell net-tools && \
        bash "$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh" "$WIN_USER" latest latest "$WSL_DISTRO_NAME" && cd "$orig_pwd" || cd "$orig_pwd" 
    fi
fi
if [ "$nix_user" = "root" ]; then
    echo "
build/install kernel for WSL?"
    read -r -p "
(no)
" build_kernel
    if [ "${build_kernel,,}" = "y" ] || [ "${build_kernel,,}" = "yes" ]; then
        sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get --with-new-pkgs -y upgrade && sudo apt-get -y install alien autoconf bison bc build-essential console-setup cpio dbus-user-session daemonize dwarves fakeroot \
        flex fontconfig gawk kmod libblkid-dev libffi-dev lxcfs libudev-dev libaio-dev libattr1-dev libelf-dev libpam-systemd \
        python3-dev python3-setuptools python3-cffi net-tools rsync snapd systemd-sysv sysvinit-utils uuid-dev zstd && \
        sudo apt-get -y upgrade && sudo apt-get --with-new-pkgs -y upgrade 
    echo "
build stable kernel for WSL? (ZFS available)"
        read -r -p "
(no)
" install_stable_kernel
        if [ "${install_stable_kernel,,}"  = "y" ] || [ "${install_stable_kernel,,}" = "yes" ]; then
                echo "
    build stable kernel for WSL with ZFS?"
            read -r -p "
    (no)
    " install_stable_zfs_kernel
            if [ "${install_stable_zfs_kernel,,}"  = "y" ] || [ "${install_stable_zfs_kernel,,}" = "yes" ] || [ "${install_stable_zfs_kernel}" = "" ]; then
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "stable" "" "zfs" "$WIN_USER"
                    sudo bash build-export-kernel.sh "stable" "" "zfs" "$WIN_USER" && \
                    sudo bash install-kernel.sh "$WIN_USER" "latest"
                    cd "$orig_pwd" || exit
                else
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "stable" "" "" "$WIN_USER"
                    sudo bash build-export-kernel.sh "stable" "" "" "$WIN_USER" && \
                    sudo bash install-kernel.sh "$WIN_USER" "latest"
                    cd "$orig_pwd" || exit
                fi 
        else 
        
            echo "
build latest kernel for WSL? (ZFS available)"
            read -r -p "
(no)
" install_latest_kernel
            if [ "${install_latest_kernel,,}"  = "y" ] || [ "${install_latest_kernel,,}" = "yes" ]; then
                echo "
    build latest kernel for WSL with ZFS?"
                read -r -p "
    (no)
    " install_latest_zfs_kernel
                if [ "${install_latest_zfs_kernel,,}"  = "y" ] || [ "${install_latest_zfs_kernel,,}" = "yes" ] || [ "${install_latest_zfs_kernel}" = "" ]; then
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "latest" "" "zfs" "$WIN_USER"
                    sudo bash build-export-kernel.sh "latest" "" "zfs" "$WIN_USER" && \
                    sudo bash install-kernel.sh "$WIN_USER" "latest"
                    cd "$orig_pwd" || exit
                else
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "latest" "" "" "$WIN_USER"
                    sudo bash build-export-kernel.sh "latest" "" "" "$WIN_USER" && \
                    sudo bash install-kernel.sh "$WIN_USER" "latest"
                    cd "$orig_pwd" || exit
                fi 
            fi 

            echo "
build basic kernel for WSL (ZFS available ZFS)?"
            read -r -p "
(yes)
" install_basic_kernel
            if [ "${install_basic_kernel,,}"  = "" ] || [ "${install_basic_kernel,,}"  = "y" ] || [ "${install_latest_kernel,,}" = "yes" ]; then
                echo "
    build basic kernel for WSL with ZFS?"
                read -r -p "
    (yes)
    " install_basic_zfs_kernel
                if  [ "${install_basic_zfs_kernel,,}"  = "" ] || [ "${install_basic_zfs_kernel,,}"  = "y" ] || [ "${install_basic_zfs_kernel,,}" = "yes" ] || [ "${install_basic_zfs_kernel}" = "" ]; then
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "basic" "" "zfs" "$WIN_USER"
                    sudo bash build-export-kernel.sh "basic" "" "zfs" "$WIN_USER" && \
                    sudo bash install-kernel.sh "$WIN_USER" "latest"
                    cd "$orig_pwd" || exit
                else
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "basic" "" "" "$WIN_USER"
                    sudo bash build-export-kernel.sh "basic" "" "" "$WIN_USER" && \
                    sudo bash install-kernel.sh "$WIN_USER" "latest"
                    cd "$orig_pwd" || exit
                fi 
            fi      
        fi
    fi
    if ls /kache/*.tar.gz 1> /dev/null 2>&1; then
        kernel_tar_path=$(ls -txr1 /kache/*.tar.gz  | tail --lines=1)
        kernel_tar_file=$(echo "$kernel_tar_path") 
        kernel_tar_filename=${kernel_tar_file%.*}
        kernel_tar_filename=${kernel_tar_filename%.*}
        echo "
        import ${kernel_tar_filename} into WSL?"
        read -r -p "
        (yes)
        " import_kernel
        if [ "${import_kernel,,}" = "y" ] || [ "${import_kernel,,}" = "yes" ] || [ "${import_kernel,,}" = "" ]; then
            
            sudo mkdir -p "$WIN_USER_HOME/kache"
            sudo chown -R "${_AGL:agl}:halo" "$WIN_USER_HOME/kache"
            bash "$HOME/k-home.sh" && \
            sudo cp -rfv "$kernel_tar_path" "/mnt/c/users/$WIN_USER$kernel_tar_path" && \
            cd "$WIN_USER_HOME/kache" && \
            sudo tar --overwrite -xzvf "${kernel_tar_filename}.tar.gz" && \
            # bash update-initramfs -u -k !wsl_default_kernel! 
            sudo apt-get -yq install powershell net-tools && \
            bash "$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh" "$WIN_USER" latest latest "$WSL_DISTRO_NAME" && cd "$orig_pwd" || cd "$orig_pwd" 
        fi
    fi    
fi

# update install apt-utils dialog kali-linux-headless upgrade

echo "
install/update dependencies?"
    read -r -p "
(yes)
" update_upgrade
if [ "${update_upgrade,,}" != "n" ] && [ "${update_upgrade,,}" != "n" ]; then
    sudo rm -rf /var/lib/apt/lists && \
    sudo rm -rf /etc/ssl/certs && \
    sudo apt-get update --fix-missing -yq && sudo apt-get install -f && sudo apt-get upgrade -yq && \
    sudo apt-get install -yq powershell net-tools zstd && \
    sudo apt-get --reinstall -yq install ca-certificates && \
    sudo update-ca-certificates && \
    # sudo apt-get remove -yq ca-certificates-java 
    sudo locale-gen en_US.UTF-8 && \
    sudo dpkg-reconfigure locales 
fi

# cdir install
echo "
install cdir?"
read -r -p "
(no)
" install_cdir
if [ "${install_cdir,,}"  = "y" ] || [ "${install_cdir,,}" = "yes" ]; then
    sudo rm -rf /var/lib/apt/lists && \
    sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get --with-new-pkgs -y upgrade && \
    sudo apt-get install --no-install-recommends -y jq python3-pip python3-venv && \
    pip3 install pip --upgrade --no-warn-script-location --no-deps && \
    pip3 install cdir --user && \
    sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get --with-new-pkgs -y upgrade
fi

echo "
build minimal KEX gui?"
read -r -p "
(yes)
" build_kex
if [ "${build_kex}" = "" ] || [ "${build_kex,,}" = "y" ] || [ "${build_kex,,}" = "yes" ]; then

    # sudo apt --reinstall --no-install-suggests -y virtualbox vlc x11-apps xrdp xfce4 xfce4-goodies lightdm kali-defaults kali-root-login desktop-base kali-win-kex
    sudo apt-get install --install-recommends -yq apt-transport-https curl
    sudo dpkg --add-architecture i386 && \
    sudo apt-get -y update && sudo apt-get- y upgrade && sudo apt-get --with-new-pkgs -y upgrade && \
    sudo apt-get -y install apt-utils kali-defaults kali-root-login kali-win-kex kali-linux-headless lightdm virtualbox vlc wine32:i386 x11-apps xrdp xfce4 xfce4-goodies
    sudo rm -rf /var/lib/apt/lists && \
    sudo rm -rf /var/cache/apt/archives/*.deb && \
    sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get --with-new-pkgs -y upgrade
    sudo apt-get install -y desktop-base
fi 
echo "
    build full KEX gui?"
    read -r -p "
    (yes)
    " build_kex
    if [ "${build_kex}" = "" ] || [ "${build_kex,,}" = "y" ] || [ "${build_kex,,}" = "yes" ]; then
        sudo apt --reinstall -y desktop-base
    fi

echo "
        install brave browser?"
        read -r -p "
        (yes)
        " install_brave
        if [ "${install_brave}" = "" ] || [ "${install_brave,,}" = "y" ] || [ "${install_brave,,}" = "yes" ]; then
            sudo rm -rf /etc/ssl/certs
            sudo apt-get update --fix-missing -yq && sudo apt-get install -f && sudo apt-get upgrade -yq && \
            sudo apt-get --reinstall -yq install ca-certificates && \
            sudo update-ca-certificates && \
            sudo apt-get remove -yq ca-certificates-java && \
            sudo apt-get install --install-recommends -yq apt-transport-https curl 
            sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg 
            sudo echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list 
            # sudo rm -rf /var/lib/apt/lists && \
            sudo rm -rf /var/cache/apt/archives/*.deb && \
            sudo apt-get update -yq && sudo apt-get upgrade -yq && sudo apt-get --with-new-pkgs upgrade -yq && \
            # # sudo dpkg-reconfigure libdvd-pkg 
            sudo apt-get install -yq brave-browser virtualbox vlc x11-apps
            
        fi

# services can be turned on now
echo 'exit 0' | sudo tee /usr/sbin/policy-rc.d
# make files executable
sudo chmod +x k-home.sh start-kde.sh start-kex.sh setup.sh reclone-gh.sh 

# k-home
ls -al "$HOME" && \
echo "
pull k-home files from repo to $HOME?" && \
read -r -p "
(no)
" update_home
if [ "${update_home,,}"  = "y" ] || [ "${update_home,,}" = "yes" ]; then
    sudo echo 'exit 0' | sudo tee /usr/sbin/policy-rc.d
    sudo service docker start
    cp -fv "$HOME/dvlw/dvlp/mnt/HOME_NIX/k-home.sh" "$HOME/k-home.sh"
    bash "$HOME/k-home.sh" "$WIN_USER"
    ls -al "$HOME"
fi
if [ "$nix_user" != "r00t" ]; then
    echo "

    pull k-home files from repo to /etc?"
    read -r -p "
    (no)
    " update_home
    if [ "${update_home,,}"  = "y" ] || [ "${update_home,,}" = "yes" ]; then
        sudo cp -rfv "$HOME/dvlw/dvlp/mnt/etc/" "/"
    fi
fi

cd "$orig_pwd" || exit
if [ "$WIN_USER_HOME" != "" ]; then
    ls -al "$WIN_USER_HOME"
    echo "
pull k-home files from repo to $WIN_USER_HOME ?"
    read -r -p "
(no)
" update_home
    if [ "${update_home,,}"  = "y" ] || [ "${update_home,,}" = "yes" ]; then
        cp -fv "$WIN_USER_HOME/repos/kindtek/dvlw/dvlp/mnt/HOME_WIN/k-home.sh" "$WIN_USER_HOME/k-home.sh"
        cd "$WIN_USER_HOME" || exit
        sudo echo 'exit 0' | sudo tee /usr/sbin/policy-rc.d
        sudo service docker start
        bash "$WIN_USER_HOME/k-home.sh" "$WIN_USER"
        cd "$orig_pwd" || exit
        ls -al "$WIN_USER_HOME"
    fi
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
else
    echo "
generate ssh keys?"
    read -r -p "
(yes)
" regen_ssh
    if [ "${regen_ssh}" = "" ] || [ "${regen_ssh,,}" = "y" ] || [ "${regen_ssh,,}" = "yes" ]; then
        confirm_regen="r"
    else 
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

# enable virtual network
echo "
convert virtual network connection to bridged? (requires elevated access privileges)"
read -r -p "
(no)
" convert_net
if [ "${convert_net,,}"  = "y" ] || [ "${convert_net,,}" = "yes" ]; then
    sudo rm -rf /var/lib/apt/lists && \
    sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get --with-new-pkgs -y upgrade -y &&
    sudo dpkg --add-architecture i386 &&
    sudo apt-get install -y powershell net-tools wine32:i386
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-file \"${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1\"" || \
    pwsh.exe -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || powershell.exe -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || pwsh -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || echo "
------------------------------- copy_start -------------------------------

$(tail -n +10 ${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1)

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
    sudo rm -rf /var/lib/apt/lists && \
    sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get --with-new-pkgs -y upgrade
    sudo apt-get install net-tools powershell wine32:i386
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-file \"${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1\"" || \
    pwsh.exe -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || powershell.exe -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1"  || pwsh -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || echo "
------------------------------- copy_start -------------------------------

#Remove Firewall Exception Rules
Invoke-Expression \"Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock Outbound'\";
Invoke-Expression \"Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock Inbound'\";

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

echo "

finishing up...

"
# echo "
# build KDE gui?"
# read -r -p "
# (no)
# " build_kde
# if [ "${build_kde,,}"  = "y" ] || [ "${build_kde,,}" = "yes" ]; then
#     ./start-kde.sh "$WIN_USER"
# fi
# echo 'start services?'
# read -r -p "
# (yes)" start_services
# if [ "$start_services" = "" ] || [ "${start_services,,}" = "y" ] || [ "${start_services,,}" = "yes" ]; then
    sudo apt-get install -yq console-setup dialog
    sudo apt-get update -yq && sudo apt-get --with-new-pkgs upgrade -y
# fi

echo "setup operation complete ..."
# sudo apt-get install -y aptitude
# sudo aptitude purge nvidia-current
# sudo systemctl set-default graphical.target
# sudo apt-get install xserver-xephyr accountsservice dialog apt-utils
# sudo systemctl unmask lightdm.service
# sudo systemctl daemon-reload
# sudo echo 'exit 0' > /usr/sbin/policy-rc.d
# sudo chmod +x /usr/sbin/policy-rc.d
# sudo dpkg-reconfigure locales lightdm
# sudo systemctl enable xrdp-sesman.service
# sudo systemctl enable xrdp.service
# sudo systemctl enable systemd-journald-audit.socket
# sudo systemctl enable upower.service
# sudo apt-get -y install lightdm-gtk-greeter
# sudo apt-get install -y --reinstall lightdm kali-defaults kali-root-login desktop-base kali-win-kex
# sudo mkdir -p /var/lib/lightdm/data
# sudo apt-get install --reinstall gnome-session
# make modules_install
