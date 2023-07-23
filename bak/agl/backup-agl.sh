#!/bin/bash

backup_mnt_location=${1:-/mnt/data}
username=${_AGL:${username}}
groupname=halo

if [ -z $backup_mnt_location ]
then 
    export backup_mnt_location=/mnt/data/bak
fi
if [ -z $WSL_DISTRO_NAME ] 
then
    export WSL_DISTRO_NAME=orig
fi

sudo mkdir -p ${backup_mnt_location}/${username}/${username}-orig && \
sudo mkdir -p ${backup_mnt_location}/${username}/${username}-orig && \
sudo mkdir -p ${backup_mnt_location}/${username}/dvl-orig && \
sudo mkdir -p ${backup_mnt_location}/dvl/dvl-orig && \
sudo chown ${username}:${groupname} ${backup_mnt_location}/${username} && \
sudo chown ${username}:${groupname} ${backup_mnt_location}/${username}/${username}-orig && \
sudo chown ${username}:halo ${backup_mnt_location}/${username} && \
sudo chown ${username}:halo ${backup_mnt_location}/${username}/${username}-orig && \
sudo chown ${username}:hell ${backup_mnt_location}/dvl && \
sudo chown ${username}:hell ${backup_mnt_location}/dvl/dvl-orig && \
# sudo chown dvl:hell ${backup_mnt_location}/${username}/dvl-orig && 
sudo chown dvl:hell ${backup_mnt_location}/${username}/dvl-orig && \
# sudo chown dvl:hell ${backup_mnt_location}/${username} && 
sudo chown dvl:hell ${backup_mnt_location}/${username}/dvl-orig && \
sudo chown dvl:hell ${backup_mnt_location}/${username}/dvl-orig && \

# copy newly pulled backup script to mount location and home dirs
sudo cp -arfv dvlw/mnt/backup-${username}.sh ${backup_mnt_location}/${username}/backup-${username}.sh && cp -arfv dvlw/mnt/backup-${username}.sh /home/${username}/backup-${username}.sh  && \
sudo cp -arfv dvlw/mnt/backup-custom.sh ${backup_mnt_location}/${username}/backup-${username}.sh && cp -arfv dvlw/mnt/backup-custom.sh /home/${username}/backup-${username}.sh && \
sudo cp -arfv dvlw/mnt/backup-custom.sh ${backup_mnt_location}/${username}/backup-${username}.sh && cp -arfv dvlw/mnt/backup-custom.sh /home/${username}/${username}.sh && \
sudo cp -arfv dvlw/mnt/backup-custom.sh ${backup_mnt_location}/${username}/backup-${username}.sh && cp -arfv dvlw/mnt/backup-${username}.sh /home/${username}/${username}.sh && \
sudo cp -arfv dvlw/mnt/backup-custom.sh ${backup_mnt_location}/${username}/backup-${username}.sh && cp -arfv dvlw/mnt/backup-custom.sh /home/${username}/backup-${username}.sh && \
sudo cp -arfv dvlw/mnt/backup-dvl.sh ${backup_mnt_location}/dvl/backup-dvl.sh && \
sudo cp -arfv dvlw/mnt/backup-dvl.sh ${backup_mnt_location}/${username}/backup-dvl.sh && cp -arfv dvlw/mnt/backup-dvl.sh /home/${username}/backup-dvl.sh  && \
sudo cp -arfv dvlw/mnt/backup-dvl.sh ${backup_mnt_location}/${username}/backup-dvl.sh && cp -arfv dvlw/mnt/backup-dvl.sh /home/${username}/backup-dvl.sh  && \
sudo cp -arfv dvlw/mnt/backup-dvl.sh /home/dvl/backup-dvl.sh && \
# # make rwx for owner and rx for group - none for others
# sudo chmod 750 -R ${backup_mnt_location}/${username} && \
# sudo chmod 755 ${backup_mnt_location}/${username} && \
# sudo chmod 750 -R ${backup_mnt_location}/${username} && \
# sudo chmod 755 ${backup_mnt_location}/${username} && \
# sudo chmod 750 -R ${backup_mnt_location}/dvl && \
# # # add warning for the backup drive
# echo "!!!!!!!!!!!!!!!!DO NOT SAVE YOUR FILES IN THIS DIRECTORY!!!!!!!!!!!!!!!!\n\nThe devel can/will delete your files if you save them in this directory. Keep files out of the devels grasp and in the *${username}* sub-directory.\n\n!!!!!!!!!!!!!!!!DO NOT SAVE YOUR FILES IN THIS DIRECTORY!!!!!!!!!!!!!!!!" | sudo tee ${backup_mnt_location}/README_ASAP      && \
# echo "!!!!!!!!!!!!!!!!DO NOT SAVE YOUR FILES IN THIS DIRECTORY!!!!!!!!!!!!!!!!\n\nThe devel can/will delete your files if you save them in this directory. Keep files out of the devels grasp and in the *${username}* sub-directory.\n\n!!!!!!!!!!!!!!!!DO NOT SAVE YOUR FILES IN THIS DIRECTORY!!!!!!!!!!!!!!!!" | sudo tee ${backup_mnt_location}/${username}/README_ASAP      && \
# echo "!!!!!!!!!!!!!!!!DO NOT SAVE YOUR FILES IN THIS DIRECTORY!!!!!!!!!!!!!!!!\n\nThe devel can/will delete your files if you save them in this directory. Keep files out of the devels grasp and in the *${username}* sub-directory.\n\n!!!!!!!!!!!!!!!!DO NOT SAVE YOUR FILES IN THIS DIRECTORY!!!!!!!!!!!!!!!!" | sudo tee ${backup_mnt_location}/${username}/README_ASAP      && \
# sudo chown ${username}:${groupname} ${backup_mnt_location}/README_ASAP

HALO_DESTINATION="$backup_mnt_location/${username}/dvl-$WSL_DISTRO_NAME";
HALO_RESTORE_SCRIPT="$backup_mnt_location/${username}/restore-${username}-$WSL_DISTRO_NAME.sh"

echo "backing the /halo up to: $HALO_DESTINATION ...";

export VERSION_CONTROL=numbered;

mkdir -p $HALO_DESTINATION;
cp -arfv --backup=$VERSION_CONTROL --update /home/dvl $HALO_DESTINATION;

echo "creating restore script and saving as $HALO_RESTORE_SCRIPT ...";

echo "#!/bin/bash
# run as sudo

echo 'restoring $backup_mnt_location/${username}/dvl-$WSL_DISTRO_NAME/dvl to /home ...';
cp --backup=$VERSION_CONTROL --remove-destination -arfv $backup_mnt_location/${username}/dvl-$WSL_DISTRO_NAME/dvl /home" > $HALO_RESTORE_SCRIPT;

chown dvl:hell $HALO_RESTORE_SCRIPT;
chmod +x $HALO_RESTORE_SCRIPT;

echo "Backup complete.";
