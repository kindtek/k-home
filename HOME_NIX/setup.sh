#!/bin/bash
orig_win_user=$WIN_USER
WIN_USER=$1
# if arg2 empty skip import kernel and do quick install
setup_type=${2:+'full'}
setup_type=${2:-'quick'}
if [ "${2,,}" != "import" ]; then
    import_kernel='n'
else
    import_kernel='y'
    quick_import_kernel='y'
fi
ssh_dir_default=$HOME/.ssh
confirm_regen="r"
warning=""
orig_pwd=$(pwd)
nix_user=$(whoami)
nix_group=$(id -g -n)

if [ "$WIN_USER" != "" ] && [ -d "/mnt/c/users/$WIN_USER" ]; then
    echo "setting linux environment variables for $WIN_USER"
    set -x
    WIN_USER_HOME=/mnt/c/users/$WIN_USER
    WIN_USER_KACHE=/mnt/c/users/$WIN_USER/kache
    export WIN_USER
    export WIN_USER_HOME
    export WIN_USER_KACHE
    PATH="$PATH:$WIN_USER_KACHE"
    set +x
elif [ "$orig_win_user" != "" ] && [ -d "/mnt/c/users/$orig_win_user" ]; then
    WIN_USER=$orig_win_user
    echo "setting linux environment variables for $WIN_USER"
    set -x
    WIN_USER_HOME=/mnt/c/users/$WIN_USER
    WIN_USER_KACHE=/mnt/c/users/$WIN_USER/kache
    export WIN_USER
    export WIN_USER_HOME
    export WIN_USER_KACHE
    PATH="$PATH:$WIN_USER_KACHE"
    set +x
fi

# %USERPROFILE% integration
while [ ! -d "/mnt/c/users/$WIN_USER" ]; do
    [ ! -d "/mnt/c/users" ] || cd "/mnt/c/users" || break
    if [ ! -d "/mnt/c/users" ]; then
        if [ ! -d "/mnt/c/users/$WIN_USER" ]; then
            echo "/mnt/c/users/$WIN_USER is not a directory - skipping prompt for home directory"
        fi
        break
    fi
    echo " 


integrate windows home directory?

this directory will be used for:
    - WSL configuration management
    - kernel installations
    - syncing home directories and devels workshop repo

    choose from:
    "
    ls -da /mnt/c/users/*/ | tail -n +4 | sed -r -e 's/^\/mnt\/c\/users\/([ A-Za-z0-9]*)*\/+$/\t\1/g'

    read -r -p "

(skip)  C:\\users\\" WIN_USER
    if [ "$WIN_USER" = "" ]; then

        break
    fi
    if [ ! -d "/mnt/c/users/$WIN_USER" ]; then
        echo "

        
        
        







C:\\users\\$WIN_USER is not a home directory"
    else
        echo "setting linux environment variables for $WIN_USER"
        set -x
        WIN_USER_HOME=/mnt/c/users/$WIN_USER
        WIN_USER_KACHE=/mnt/c/users/$WIN_USER/kache
        export WIN_USER
        export WIN_USER_HOME
        export WIN_USER_KACHE
        PATH="$PATH:$WIN_USER_KACHE"
        set +x
    fi
done

# kernel import stuff
while [ "${import_kernel,,}" != "n" ] && [ "${import_kernel,,}" != "no" ]; do
    if ls /kache/*.tar.gz 1>/dev/null 2>&1 && [ -f "$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh" ]; then
        kernel_tar_path=$(ls -txr1 /kache/*.tar.gz | tail --lines=1)
        kernel_tar_file=${kernel_tar_path##*/}
        kernel_tar_filename=${kernel_tar_file%.*}
        kernel_tar_filename=${kernel_tar_filename%.*}
        # if import_kernel was preset to y or import_kernel was not reset to 'n' then read input - otherwise skip to importing
        if [ "${quick_import_kernel,,}" = "y" ]; then
            echo "
WINDOWS
user $WIN_USER

import ${kernel_tar_filename} into WSL?" &&
                read -r -p "
(yes)
" import_kernel
        fi
        if [ "${import_kernel,,}" = "y" ] || [ "${import_kernel,,}" = "yes" ] || [ "${import_kernel,,}" = "" ]; then
            # set -x
            WIN_USER_KACHE="/mnt/c/users/$WIN_USER/kache"
            sudo mkdir -p "$WIN_USER_KACHE"
            sudo rm -rf "/mnt/c/users/$WIN_USER/kache/usr" "/mnt/c/users/$WIN_USER/kache/lib" "/mnt/c/users/$WIN_USER/kache/src" "/mnt/c/users/$WIN_USER/kache/boot"
            sudo chown -R "${nix_user}:${nix_group}" /mnt/c/users/"$WIN_USER"/wsl-* "$WIN_USER_KACHE"/wsl-* "$WIN_USER_KACHE"/.wsl* /mnt/c/users/"$WIN_USER"/.wsl* "$WIN_USER_KACHE"/*_* "$WIN_USER_KACHE" "$kernel_tar_path"
            # set +x
            bash "$HOME/k-home.sh" &&
                sudo cp -rfv "$kernel_tar_path" "$WIN_USER_KACHE/$kernel_tar_file" &&
                cd "$WIN_USER_KACHE" &&
                sudo tar --owner="${nix_user}" --group="${nix_group}" --overwrite -xzvf "${kernel_tar_filename}.tar.gz" &&
                sudo chown -R "${nix_user}:${nix_group}" /mnt/c/users/"$WIN_USER"/wsl-* "$WIN_USER_KACHE"/wsl-* "$WIN_USER_KACHE"/.wsl* /mnt/c/users/"$WIN_USER"/.wsl* "$WIN_USER_KACHE"/*_* "$WIN_USER_KACHE" "$kernel_tar_path"
            sudo chmod +x "/mnt/c/users/$WIN_USER"/wsl-* "$WIN_USER_KACHE"/wsl-* "$WIN_USER_KACHE"/.wsl* "$WIN_USER_KACHE"/*_* "$kernel_tar_path"
            # sudo chown -R "${nix_user}:$(id -g -n)" "$WIN_USER_KACHE"
            # bash update-initramfs -u -k !wsl_default_kernel!
            sudo apt-get -yqq install powershell net-tools &&
                echo "running bash '$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh' '$WIN_USER' 'latest' 'latest' '$WSL_DISTRO_NAME'"
            bash "$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh" "$WIN_USER" 'latest' 'latest' "$WSL_DISTRO_NAME" && cd "$orig_pwd" || cd "$orig_pwd"
            pwsh "$HOME/dvlw/dvlp/kernels/linux/kache/wsl-restart.ps1"
        else
            WIN_USER_KACHE="/mnt/c/users/$WIN_USER/kache"
            if ls /kache/*.tar.gz 1>/dev/null 2>&1 || ls "$WIN_USER_KACHE"*.tar.gz 1>/dev/null 2>&1; then
                kernel_tar_paths=$(ls -txr /kache/*.tar.gz)
                kernel_tar_paths+=$(ls -txr "$WIN_USER_KACHE"/*.tar.gz)

                i=0
                for kernel_tar_path in $kernel_tar_paths; do
                    kernel_tar_file=${kernel_tar_path##*/}
                    kernel_tar_filename=${kernel_tar_file%.*}
                    kernel_tar_filename=${kernel_tar_filename%.*}
                    i=$((i + 1))
                    echo "$i) $kernel_tar_filename"
                done
                echo "
    WINDOWS
    user $WIN_USER
            
    import [number] into WSL?"
                read -r -p "
    (skip)
    " import_kernel_num
                if [ "${import_kernel_num,,}" -le $i ] && [ "${import_kernel_num,,}" -gt 0 ]; then
                    # set -x
                    sudo mkdir -p "$WIN_USER_KACHE"
                    sudo rm -rf "/mnt/c/users/$WIN_USER/kache/usr" "/mnt/c/users/$WIN_USER/kache/lib" "/mnt/c/users/$WIN_USER/kache/src" "/mnt/c/users/$WIN_USER/kache/boot"
                    sudo chown -R "${nix_user}:${nix_group}" /mnt/c/users/"$WIN_USER"/wsl-* "$WIN_USER_KACHE"/wsl-* "$WIN_USER_KACHE"/.wsl* /mnt/c/users/"$WIN_USER"/.wsl* "$WIN_USER_KACHE"/*_* "$WIN_USER_KACHE" "$kernel_tar_path"
                    # set +x
                    kernel_tar_file=${kernel_tar_paths}[$((import_kernel_num - 1))]
                    kernel_tar_file=${kernel_tar_file##*/}
                    bash "$HOME/k-home.sh" &&
                        # the tar is in one of these places but copy to both
                        sudo cp -rfv "$kernel_tar_path" "$WIN_USER_KACHE/$kernel_tar_file" &&
                        sudo cp -rfv "$kernel_tar_path" "/kache/$kernel_tar_file" &&
                        cd "$WIN_USER_KACHE" &&
                        sudo tar --owner="${nix_user}" --group="${nix_group}" --overwrite -xzvf "${kernel_tar_filename}.tar.gz" &&
                        sudo chown -R "${nix_user}:${nix_group}" /mnt/c/users/"$WIN_USER"/wsl-* "$WIN_USER_KACHE"/wsl-* "$WIN_USER_KACHE"/.wsl* /mnt/c/users/"$WIN_USER"/.wsl* "$WIN_USER_KACHE"/*_* "$WIN_USER_KACHE" "$kernel_tar_path"
                    sudo chmod +x "/mnt/c/users/$WIN_USER"/wsl-* "$WIN_USER_KACHE"/wsl-* "$WIN_USER_KACHE"/.wsl* "$WIN_USER_KACHE"/*_* "$kernel_tar_path"
                    # sudo chown -R "${nix_user}:$(id -g -n)" "$WIN_USER_KACHE"
                    # bash update-initramfs -u -k !wsl_default_kernel!
                    sudo apt-get -yqq install powershell net-tools &&
                        echo "running bash '$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh' '$WIN_USER' 'latest' 'latest' '$WSL_DISTRO_NAME'"
                    bash "$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh" "$WIN_USER" 'latest' 'latest' "$WSL_DISTRO_NAME" && cd "$orig_pwd" || cd "$orig_pwd"
                    pwsh "$HOME/dvlw/dvlp/kernels/linux/kache/wsl-restart.ps1"
                fi
            fi
        fi
    fi
    if [ "$nix_user" = "root" ] && [ -f "$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh" ]; then
        if [ "${build_kernel,,}" != "y" ] && [ "${build_kernel,,}" != "yes" ]; then
            echo "
    build/install kernel for WSL?"
            read -r -p "
    (no)
    " build_kernel
        else
            build_kernel=n
        fi
        if [ "${build_kernel,,}" = "y" ] || [ "${build_kernel,,}" = "yes" ]; then
            import_kernel='y'
            sudo apt-get -yqq update && sudo apt-get -yqq upgrade && sudo apt-get --with-new-pkgs -yqq upgrade && sudo apt-get -yqq install alien autoconf bison bc build-essential console-setup cpio dbus-user-session daemonize dwarves fakeroot \
                flex fontconfig gawk kmod libblkid-dev libffi-dev lxcfs libudev-dev libaio-dev libattr1-dev libelf-dev libpam-systemd \
                python3-dev python3-setuptools python3-cffi net-tools rsync snapd systemd-sysv sysvinit-utils uuid-dev zstd &&
                sudo apt-get -yqq upgrade && sudo apt-get --with-new-pkgs -yqq upgrade
            echo "
        build stable kernel for WSL? (ZFS available)"
            read -r -p "
        (yes)
        " install_stable_kernel
            if [ "${install_stable_kernel,,}" = "" ] || [ "${install_stable_kernel,,}" = "y" ] || [ "${install_stable_kernel,,}" = "yes" ]; then
                echo "
            build stable kernel for WSL with ZFS?"
                read -r -p "
            (yes)
            " install_stable_zfs_kernel
                if [ "${install_stable_zfs_kernel,,}" = "" ] || [ "${install_stable_zfs_kernel,,}" = "y" ] || [ "${install_stable_zfs_kernel,,}" = "yes" ] || [ "${install_stable_zfs_kernel}" = "" ]; then
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "stable" "" "zfs"
                    sudo bash build-export-kernel.sh "stable" "" "zfs" &&
                        # sudo bash install-kernel.sh "latest" "latest"
                        cd "$orig_pwd" || exit
                else
                    cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                    echo sudo bash build-export-kernel.sh "stable" "" ""
                    sudo bash build-export-kernel.sh "stable" "" "" &&
                        # sudo bash install-kernel.sh "latest" "latest"
                        cd "$orig_pwd" || exit
                fi
                sudo bash dkms autoinstall --modprobe-on-install --kernelsourcedir "$LFS"
            else

                echo "
        build latest kernel for WSL? (ZFS available)"
                read -r -p "
        (no)
        " install_latest_kernel
                if [ "${install_latest_kernel,,}" = "y" ] || [ "${install_latest_kernel,,}" = "yes" ]; then
                    echo "
            build latest kernel for WSL with ZFS?"
                    read -r -p "
            (no)
            " install_latest_zfs_kernel
                    if [ "${install_latest_zfs_kernel,,}" = "y" ] || [ "${install_latest_zfs_kernel,,}" = "yes" ] || [ "${install_latest_zfs_kernel}" = "" ]; then
                        cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                        echo sudo bash build-export-kernel.sh "latest" "" "zfs"
                        sudo bash build-export-kernel.sh "latest" "" "zfs" &&
                            # sudo bash install-kernel.sh "latest" "latest"
                            cd "$orig_pwd" || exit
                    else
                        cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                        echo sudo bash build-export-kernel.sh "latest" "" ""
                        sudo bash build-export-kernel.sh "latest" "" "" &&
                            # sudo bash install-kernel.sh "latest" "latest"
                            cd "$orig_pwd" || exit
                    fi
                    sudo bash dkms autoinstall --modprobe-on-install --kernelsourcedir "$LFS"
                fi

                echo "
        build basic kernel for WSL (ZFS available ZFS)?"
                read -r -p "
        (no)
        " install_basic_kernel
                if [ "${install_basic_kernel,,}" = "y" ] || [ "${install_latest_kernel,,}" = "yes" ]; then
                    echo "
            build basic kernel for WSL with ZFS?"
                    read -r -p "
            (yes)
            " install_basic_zfs_kernel
                    if [ "${install_basic_zfs_kernel,,}" = "" ] || [ "${install_basic_zfs_kernel,,}" = "y" ] || [ "${install_basic_zfs_kernel,,}" = "yes" ] || [ "${install_basic_zfs_kernel}" = "" ]; then
                        cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                        echo sudo bash build-export-kernel.sh "basic" "" "zfs"
                        sudo bash build-export-kernel.sh "basic" "" "zfs" &&
                            # sudo bash install-kernel.sh "latest" "latest"
                            cd "$orig_pwd" || exit
                    else
                        cd "$HOME/dvlw/dvlp/kernels/linux" || exit
                        echo sudo bash build-export-kernel.sh "basic" "" ""
                        sudo bash build-export-kernel.sh "basic" "" "" &&
                            # sudo bash install-kernel.sh "latest" "latest"
                            cd "$orig_pwd" || exit
                    fi
                    sudo bash dkms autoinstall --modprobe-on-install --kernelsourcedir "$LFS"
                fi
            fi
        else
            import_kernel="n"
        fi
    elif [ -f "$HOME/dvlw/dvlp/kernels/linux/install-kernel.sh" ]; then
        if [ "${build_kernel,,}" != "y" ] && [ "${build_kernel,,}" != "yes" ]; then
            echo "
    
    WINDOWS
    user $WIN_USER

    build/install kernel for WSL?"
            read -r -p "
    (no)
    " build_kernel
        else
            build_kernel=n
        fi
        if [ "${build_kernel,,}" = "y" ] || [ "${build_kernel,,}" = "yes" ]; then
            import_kernel='y'
            sudo apt-get update --fix-missing -yqq && sudo apt-get install -f && sudo apt-get upgrade -yqq &&
                sudo apt-get install --no-install-recommends -yqq ca-certificates curl lsb-release gpg &&
                sudo mkdir -pv /etc/apt/keyrings &&
                [ -e "/usr/share/keyrings/docker-archive-keyring.gpg" ] || sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >/dev/null &&
                yes "y" | echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null &&
                sudo apt-get update --fix-missing -yqq && sudo apt-get install -f && sudo apt-get upgrade -yqq &&
                sudo apt-get install --no-install-recommends -yqq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gnupg
            # interop
            USERNAME=$WIN_USER
            sudo service docker start
            echo "
        build stable kernel for WSL? (ZFS available)"
            read -r -p "
        (no)
        " install_stable_kernel
            if [ "${install_stable_kernel,,}" = "y" ] || [ "${install_stable_kernel,,}" = "yes" ]; then
                echo "
            build stable kernel for WSL with ZFS?"
                read -r -p "
            (no)
            " install_stable_zfs_kernel
                if [ "${install_stable_zfs_kernel,,}" = "y" ] || [ "${install_stable_zfs_kernel,,}" = "yes" ] || [ "${install_stable_zfs_kernel}" = "" ]; then
                    cd "$HOME/dvlw/dvlp/docker/kali" || exit
                    docker compose build make-kernel-stable-zfs
                    sudo docker compose cp make-kernel-stable-zfs:/kache/ /
                    sudo docker compose cp make-kernel-stable-zfs:/r00t/dvlw/dvlp/kernels/ /r00t/dvlw/dvlp/kernels/
                    sudo chown "$nix_user:$nix_group" /kache/*.tar.gz
                    sudo chmod +x /kache/*.tar.gz
                    cd "$orig_pwd" || exit
                else
                    cd "$HOME/dvlw/dvlp/docker/kali" || exit
                    docker compose build make-kernel-stable
                    sudo docker compose cp make-kernel-stable:/kache/ /
                    sudo docker compose cp make-kernel-stable:/r00t/dvlw/dvlp/kernels/ /r00t/dvlw/dvlp/kernels/
                    sudo chown "$nix_user:$nix_group" /kache/*.tar.gz
                    sudo chmod +x /kache/*.tar.gz
                    cd "$orig_pwd" || exit
                fi
                sudo bash dkms autoinstall --modprobe-on-install --kernelsourcedir /r00t/dvlw/dvlp/kernels/linux-build-gregkh
            else

                echo "
        build latest kernel for WSL? (ZFS available)"
                read -r -p "
        (no)
        " install_latest_kernel
                if [ "${install_latest_kernel,,}" = "y" ] || [ "${install_latest_kernel,,}" = "yes" ]; then
                    echo "
            build latest kernel for WSL with ZFS?"
                    read -r -p "
            (no)
            " install_latest_zfs_kernel
                    if [ "${install_latest_zfs_kernel,,}" = "y" ] || [ "${install_latest_zfs_kernel,,}" = "yes" ] || [ "${install_latest_zfs_kernel}" = "" ]; then
                        cd "$HOME/dvlw/dvlp/docker/kali" || exit
                        docker compose build make-kernel-latest-zfs
                        sudo docker compose cp make-kernel-latest-zfs:/kache/ /
                        sudo docker compose cp make-kernel-latest-zfs:/r00t/dvlw/dvlp/kernels/ /r00t/dvlw/dvlp/kernels/
                        sudo chown "$nix_user:$nix_group" /kache/*.tar.gz
                        sudo chmod +x /kache/*.tar.gz
                        cd "$orig_pwd" || exit
                    else
                        cd "$HOME/dvlw/dvlp/docker/kali" || exit
                        docker compose build make-kernel-latest
                        sudo docker compose cp make-kernel-latest:/kache/ /
                        sudo docker compose cp make-kernel-latest:/r00t/dvlw/dvlp/kernels/ /r00t/dvlw/dvlp/kernels/
                        sudo chown "$nix_user:$nix_group" /kache/*.tar.gz
                        sudo chmod +x /kache/*.tar.gz
                        cd "$orig_pwd" || exit
                    fi
                    sudo bash dkms autoinstall --modprobe-on-install --kernelsourcedir /r00t/dvlw/dvlp/kernels/linux-build-torvalds
                fi

                echo "
        build basic kernel for WSL (ZFS available ZFS)?"
                read -r -p "
        (yes)
        " install_basic_kernel
                if [ "${install_basic_kernel,,}" = "" ] || [ "${install_basic_kernel,,}" = "y" ] || [ "${install_latest_kernel,,}" = "yes" ]; then
                    echo "
            build basic kernel for WSL with ZFS?"
                    read -r -p "
            (yes)
            " install_basic_zfs_kernel
                    if [ "${install_basic_zfs_kernel,,}" = "" ] || [ "${install_basic_zfs_kernel,,}" = "y" ] || [ "${install_basic_zfs_kernel,,}" = "yes" ] || [ "${install_basic_zfs_kernel}" = "" ]; then
                        cd "$HOME/dvlw/dvlp/docker/kali" || exit
                        docker compose build make-kernel-basic-zfs
                        sudo docker compose cp make-kernel-basic-zfs:/kache/ /
                        sudo docker compose cp make-kernel-basic-zfs:/r00t/dvlw/dvlp/kernels/ /r00t/dvlw/dvlp/kernels/
                        sudo chown "$nix_user:$nix_group" /kache/*.tar.gz
                        sudo chmod +x /kache/*.tar.gz
                        cd "$orig_pwd" || exit
                    else
                        cd "$HOME/dvlw/dvlp/docker/kali" || exit
                        docker compose build make-kernel-basic
                        sudo docker compose cp make-kernel-basic:/kache/ /
                        sudo docker compose cp make-kernel-basic:/r00t/dvlw/dvlp/kernels/ /r00t/dvlw/dvlp/kernels/
                        sudo chown "$nix_user:$nix_group" /kache/*.tar.gz
                        sudo chmod +x /kache/*.tar.gz
                        cd "$orig_pwd" || exit
                    fi
                    sudo bash dkms autoinstall --modprobe-on-install --kernelsourcedir /r00t/dvlw/dvlp/kernels/linux-build-msft
                fi
            fi
        else
            import_kernel="n"
        fi
    fi
done

# install/update/repair stuff
if [ "$setup_type" != 'quick' ]; then

    echo "

LINUX - $WSL_DISTRO_NAME
user $nix_user

install/update dependencies?"
    read -r -p "
(no)
" update_upgrade
    if [ "${update_upgrade,,}" = "y" ] && [ "${update_upgrade,,}" = "yes" ]; then
        sudo apt-get update --fix-missing -yq && apt-get install -f && apt-get upgrade -yq
        # update locales
        sudo locale-gen en_US.UTF-8 &&
            sudo dpkg-reconfigure locales
        echo "
    rebuild apt and certificate registries?"
        read -r -p "
    (no)
    " rebuild_reg
        if [ "${rebuild_reg,,}" = "y" ] || [ "${rebuild_reg,,}" = "yes" ]; then
            sudo apt-get --reinstall -yqq install ca-certificates &&
                sudo update-ca-certificates ||
                sudo rm -rf /var/lib/apt/lists &&
                sudo apt-get update --fix-missing -yqq && apt-get install -f && apt-get upgrade -yqq
            sudo rm -rf /etc/ssl/certs/* &&
                sudo apt-get --reinstall -yqq install ca-certificates &&
                sudo update-ca-certificates
            echo "
        rebuild packages?"
            read -r -p "
        (no)
        " rebuild_pkgs
            if [ "${rebuild_pkgs,,}" = "y" ] || [ "${rebuild_pkgs,,}" = "yes" ]; then
                echo "
            rebuild with suggested packages?"
                read -r -p "
            (no)
            " rebuild_pkgs_wsug
                if [ "${rebuild_pkgs_wsug,,}" = "y" ] || [ "${rebuild_pkgs_wsug,,}" = "yes" ]; then
                    for package in $(apt list --installed | grep -P ".*(?=/)" -o); do
                        sudo apt-get --reinstall --no-install-suggests -yqq install "$package"
                    done
                else
                    for package in $(apt list --installed | grep -P ".*(?=/)" -o); do
                        sudo apt-get --reinstall --install-suggests -yqq install "$package"
                    done
                fi
            fi
        fi

        sudo apt-get update --fix-missing -yqq && sudo apt-get install -f && sudo apt-get upgrade -yqq
    fi
fi

# cdir install
install_cdir=n
[ -f '.local/bin/cdir.sh' ] || echo "

LINUX - $WSL_DISTRO_NAME
user $nix_user

install cdir?"
[ -f '.local/bin/cdir.sh' ] || read -r -p "
(yes)
" install_cdir
if [ "${install_cdir}" = "" ] || [ "${install_cdir,,}" = "y" ] || [ "${install_cdir,,}" = "yes" ]; then
    sudo apt-get install --no-install-recommends -yqq jq python3-pip python3-venv &&
        pip3 install pip --upgrade --no-warn-script-location --no-deps &&
        pip3 install cdir --user &&
        sudo apt-get -yqq update && sudo apt-get -yqq upgrade && sudo apt-get --with-new-pkgs -yqq upgrade
fi

install_kvm='n'
build_gui='n'
# if [ "${setup_type,,}" != 'quick' ]; then
if [ ! -x /usr/bin/win-kex ]; then
    echo "

LINUX - $WSL_DISTRO_NAME
user $nix_user

build KEX gui?"
    if [ "$setup_type" != 'quick' ]; then
        read -r -p "
(yes)
" build_gui
        if [ "$build_gui" = "" ]; then
            build_gui='y'
        fi
    else
        read -r -p "
(no)
" build_gui
        if [ "$build_gui" = "" ]; then
            build_gui='n'
        fi
    fi
fi
if [ "${build_gui}" = "" ] || [ "${build_gui,,}" = "y" ] || [ "${build_gui,,}" = "yes" ]; then
    sudo apt-get install --install-recommends -yqq apt-transport-https accountsservice apt-utils curl kali-desktop-xfce lightdm lightdm-gtk-greeter vlc x11-apps xrdp xfce4 xfce4-goodies
    echo "
    build full KEX gui?"
    if [ "$setup_type" != 'quick' ]; then
        read -r -p "
    (yes)
    " build_full_gui
        if [ "$build_full_gui" = "" ]; then
            build_full_gui='y'
        fi
    else
        read -r -p "
    (no)
    " build_full_gui
        if [ "$build_full_gui" = "" ]; then
            build_full_gui='n'
        fi
    fi
    if [ "${build_full_gui}" = "" ] || [ "${build_full_gui,,}" = "y" ] || [ "${build_full_gui,,}" = "yes" ]; then
        # sudo apt --reinstall --no-install-suggests -yqq virtualbox vlc x11-apps xrdp xfce4 xfce4-goodies lightdm kali-defaults kali-root-login desktop-base kali-win-kex
        sudo dpkg --add-architecture i386 &&
            sudo apt-get -yqq update && sudo apt-get- y upgrade && sudo apt-get --with-new-pkgs -yqq upgrade &&
            # sudo apt-get -yqq install apt-utils kali-defaults kali-root-login kali-win-kex kali-linux-headless kali-desktop-xfce vlc wine32:i386 x11-apps xrdp xfce4 xfce4-goodies
            sudo apt-get -yqq install kali-defaults kali-root-login kali-win-kex kali-linux-headless wine32:i386
        sudo apt-get -yqq update && sudo apt-get -yqq upgrade && sudo apt-get --with-new-pkgs -yqq upgrade
        sudo apt-get install -yqq desktop-base
    else
        # sudo apt-get -yqq install apt-utils  desktop-base kali-linux-core kali-desktop-xfce vlc wine32:i386 x11-apps xrdp xfce4 xfce4-goodies

        sudo apt-get -yqq install desktop-base kali-linux-core
    fi
fi

install_goodies='n'
if [ ! -x /usr/bin/brave-browser ]; then
    echo "
            install brave browser vlc x11 and other goodies?" &&
        read -r -p "
            (yes)
    " install_goodies
fi
if [ "${install_goodies}" = "" ] || [ "${install_goodies,,}" = "y" ] || [ "${install_goodies,,}" = "yes" ]; then
    sudo apt-get update --fix-missing -yqq && sudo apt-get install -f && sudo apt-get upgrade -yqq &&
        sudo apt-get --reinstall -yqq install ca-certificates &&
        sudo update-ca-certificates &&
        sudo apt-get install --install-recommends -yqq apt-transport-https curl
    # for brave install - https://linuxhint.com/install-brave-browser-ubuntu22-04/
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg &&
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list &&
        sudo apt-get update --fix-missing -yqq && sudo apt-get install -f && sudo apt-get upgrade -yqq &&
        sudo apt-get install --no-install-recommends -yqq brave-browser vlc x11-apps &&
        # change last line of this file - fix for brave-browser displaying empty windows
        sudo cp /opt/brave.com/brave/brave-browser /opt/brave.com/brave/brave-browser.old &&
        sudo head -n -1 /opt/brave.com/brave/brave-browser.old | sudo tee /opt/brave.com/brave/brave-browser >/dev/null &&
        # now no longer need to add --disable-gpu flag everytime
        echo '"$HERE/brave" "$@" " --disable-gpu " || true' | sudo tee --append /opt/brave.com/brave/brave-browser >/dev/null
    sudo cp -rf "$HOME"/dvlw/dvlp/mnt/opt/* /opt/
fi

if [ ! -x /usr/bin/kvm ]; then
    echo "

    LINUX - $WSL_DISTRO_NAME
    user $nix_user
    
    install kvm?" &&
        read -r -p "
    (no)
    " install_kvm
fi
if [ "${install_kvm,,}" = "y" ] || [ "${install_kvm,,}" = "yes" ]; then
    echo "
        bypass kvm install prompts?"
    read -r -p "
        (yes)
        " bypass_kvm_prompts
    if [ "${build_gui}" = "" ] || [ "${build_gui,,}" = "y" ] || [ "${build_gui,,}" = "yes" ]; then
        if [ "${bypass_kvm_prompts}" = "" ] || [ "${bypass_kvm_prompts,,}" = "y" ] || [ "${bypass_kvm_prompts,,}" = "yes" ]; then
            yes "" | sudo apt-get install -yqq virt-manager qemu-system-gui qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils
        else
            sudo apt-get install -yqq virt-manager qemu-system-gui qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils
        fi
    else
        if [ "${bypass_kvm_prompts}" = "" ] || [ "${bypass_kvm_prompts,,}" = "y" ] || [ "${bypass_kvm_prompts,,}" = "yes" ]; then
            yes "" | sudo apt-get install -yqq qemu-kvm qemu-system-gui libvirt-clients libvirt-daemon-system bridge-utils
        else
            sudo apt-get install -yqq qemu-kvm qemu-system-gui libvirt-clients libvirt-daemon-system bridge-utils
        fi
    fi
fi
# fi

# services can be turned on now
echo 'exit 0' | sudo tee /usr/sbin/policy-rc.d
if [ -x /usr/bin/kvm ] || [ "${install_kvm,,}" = "y" ] || [ "${install_kvm,,}" = "yes" ]; then
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
fi

# make files executable
sudo chmod +x k-home.sh start-kde.sh start-kex.sh setup.sh reclone-gh.sh
export DEBIAN_FRONTEND=dialog

# k-home
ls -al "$HOME" &&
    echo "
LINUX - $WSL_DISTRO_NAME
user $nix_user

clone/pull devels workshop repo using git and update files in $HOME?" &&
    read -r -p "
(no)
" clone_pull_home
if [ "${clone_pull_home,,}" = "y" ] || [ "${clone_pull_home,,}" = "yes" ]; then
    cd "$HOME" || exit
    wget -O - https://raw.githubusercontent.com/kindtek/k-home/main/HOME_NIX/reclone-gh.sh | bash
    cp -rfv "$HOME/dvlw/dvlp/mnt/HOME_NIX/" "$HOME/"
fi
if [ "$setup_type" = 'quick' ]; then
    echo "
    LINUX - $WSL_DISTRO_NAME
    user $nix_user

    update environment? (update files in /etc)?"
    read -r -p "
    (no)
    " update_home
    if [ "${update_home,,}" = "y" ] || [ "${update_home,,}" = "yes" ]; then
        sudo cp -rfv "$HOME/dvlw/dvlp/mnt/etc/" "/"
    fi
fi
if [ "${clone_pull_home,,}" = "y" ] || [ "${clone_pull_home,,}" = "yes" ] || [ "$setup_type" != 'quick' ]; then
    ls -al "$HOME" &&
        echo "
LINUX - $WSL_DISTRO_NAME
user $nix_user

update devels workshop repo using docker overlay and update files in $HOME?" &&
        read -r -p "
(no)
" update_home
    if [ "${update_home,,}" = "y" ] || [ "${update_home,,}" = "yes" ]; then
        sudo echo 'exit 0' | sudo tee /usr/sbin/policy-rc.d
        sudo service docker start
        cd "$HOME" || exit
        wget -O - https://raw.githubusercontent.com/kindtek/k-home/main/HOME_NIX/k-home.sh | bash
    fi
    if [ "$nix_user" != "r00t" ]; then
        echo "
    LINUX - $WSL_DISTRO_NAME
    user $nix_user

    update environment? (update files in /etc)?"
        read -r -p "
    (no)
    " update_home
        if [ "${update_home,,}" = "y" ] || [ "${update_home,,}" = "yes" ]; then
            sudo cp -rfv "$HOME/dvlw/dvlp/mnt/etc/" "/"
        fi
    fi

    cd "$orig_pwd" || exit
    if [ "$WIN_USER_HOME" != "" ]; then
        ls -al "$WIN_USER_HOME"
        echo "
WINDOWS 
user $WIN_USER

update devels workshop repo using docker overlay and update files in $WIN_USER_HOME ?"
        read -r -p "
(no)
" update_home
        if [ "${update_home,,}" = "y" ] || [ "${update_home,,}" = "yes" ]; then
            cp -fv "$WIN_USER_HOME/repos/kindtek/dvlw/dvlp/mnt/HOME_WIN/k-home.sh" "$WIN_USER_HOME/k-home.sh"
            cd "$WIN_USER_HOME" || exit
            sudo echo 'exit 0' | sudo tee /usr/sbin/policy-rc.d
            sudo service docker start
            bash "$WIN_USER_HOME/k-home.sh"
            cp -fv "$WIN_USER_HOME/repos/kindtek/dvlw/powerhell/devel-spawn.ps1" "$WIN_USER_HOME/dvlp.ps1"
            cd "$orig_pwd" || exit
        fi
    fi
fi
# ssh gen
if [ "${setup_type,,}" != 'quick' ]; then
    if [ -f "$HOME/.ssh/known_hosts" ]; then
        echo "
LINUX - $WSL_DISTRO_NAME
user $nix_user

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
                for ((i = 0; i < uname_padding_ws_count; i++)); do
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
                for ((i = 0; i < email_padding_ws_count; i++)); do
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
                for ((i = 0; i < ssh_dir_padding_ws_count; i++)); do
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
            retrying ... "
                unset ssh_dir git_uname git_email warning
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
        git config --global user.email "$git_email"
        git config --global user.name "$git_uname"
        rm -fv "$ssh_dir/id_ed25519" "$ssh_dir/id_ed25519.pub"
        ssh-keygen -C "$git_uname" -f "$ssh_dir/id_ed25519" -N "" -t ed25519
        eval "$(ssh-agent -s)"
        ssh-add "$ssh_dir"/id_ed25519

        # quietly verify host signature before using ssh-key
        host_fingerprint_expected_rsa='github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=='
        host_fingerprint_actually_rsa="$(ssh-keyscan -t rsa github.com)"
        # quietly verify host signature before using ssh-key
        host_fingerprint_expected_ed25519='github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl'
        host_fingerprint_actually_ed25519="$(ssh-keyscan -t ed25519 github.com)"
        # quietly verify host signature before using ssh-key
        host_fingerprint_expected_ecdsa='github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg='
        host_fingerprint_actually_ecdsa="$(ssh-keyscan -t ecdsa github.com)"
        # if verified save - otherwise output error and stop

        matching_prints_rsa=false
        matching_prints_ed25519=false
        matching_prints_ecdsa=false

        if [ "$host_fingerprint_actually_ecdsa" = "$host_fingerprint_expected_ecdsa" ]; then matching_prints_rsa=true; fi
        if [ "$host_fingerprint_actually_ed25519" = "$host_fingerprint_expected_ed25519" ]; then matching_prints_ed25519=true; fi
        if [ "$host_fingerprint_actually_ecdsa" = "$host_fingerprint_expected_ecdsa" ]; then matching_prints_ecdsa=true; fi

        # gh auth login after adding to known hosts
        if [ "$matching_prints_rsa" ] && [ "$matching_prints_ed25519" ] && [ "$matching_prints_ecdsa" ]; then
            echo "
        github host confirmed and verified
        "

            if [ -f "$ssh_dir/known_hosts" ]; then
                ssh-keyscan github.com >>"$ssh_dir/known_hosts"
            else
                ssh-keyscan github.com >"$ssh_dir/known_hosts"
            fi
            gh auth login
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
        
        
    '

            if ! [ "$matching_prints_rsa" ]; then printf '\nexpected RSA:\t%s\nactual RSA:\t%s' "$host_fingerprint_expected_rsa" "$host_fingerprint_actually_rsa"; fi
            if ! [ "$matching_prints_ed25519" ]; then printf '\nexpected ED25519:\t%s\nactual ED25519:\t%s' "$host_fingerprint_expected_ed25519" "$host_fingerprint_actually_ed25519"; fi
            if ! [ "$matching_prints_ecdsa" ]; then printf '\nexpected ECDSA:\t%s\nactual ECDSA:\t%s' "$host_fingerprint_expected_ecdsa" "$host_fingerprint_actually_ecdsa"; fi

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
        
        
    '

        fi
    fi
fi

# enable virtual network
if [ "${setup_type,,}" != 'quick' ]; then

    echo "
    WINDOWS

    convert virtual network connection to bridged? (requires elevated access privileges)"
    read -r -p "
    (no)
    " convert_net
    if [ "${convert_net,,}" = "y" ] || [ "${convert_net,,}" = "yes" ]; then
        sudo dpkg --add-architecture i386 &&
            sudo apt-get update -yqq && sudo apt-get --with-new-pkgs upgrade -yqq
        sudo apt-get install -yqq powershell net-tools wine32:i386
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-file \"${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1\"" ||
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
    elif [ "${convert_net,,}" = "revert" ]; then
        sudo apt-get install net-tools powershell wine32:i386
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-file \"${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1\"" ||
            pwsh.exe -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || powershell.exe -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || pwsh -ExecutionPolicy unrestricted -file "${HOME}/dvlw/dvlp/mnt/HOME_NIX/bridge-wsl2-net.ps1" || echo "
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
sudo apt-get install -yqq console-setup dialog
export DEBIAN_FRONTEND=dialog
sudo apt-get update -yqq && sudo apt-get --with-new-pkgs upgrade -yqq
# fi

echo "setup operation complete ..."
# sudo apt-get install -yqq aptitude
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
# sudo apt-get -yqq install lightdm-gtk-greeter
# sudo apt-get install -yqq --reinstall lightdm kali-defaults kali-root-login desktop-base kali-win-kex
# sudo mkdir -p /var/lib/lightdm/data
# sudo apt-get install --reinstall gnome-session
# make modules_install
