# Version 1.01 - 02.02.2020
# https://github.com/splitti/phoniebox_rsync
# This script syncs Phoniebox-Folder to a Remote Server with rsync

######################################################################################
# PLEASE INSERT YOUR DATA HERE

# your local Phoniebox Directory without the last /
phoniebox_folder="/home/pi/RPi-Jukebox-RFID"

# your Directories to sync under phoniebox_folder; have to start and end with /
# Notice: create these folder on the remote Target
sync_dirs=( "/shared/audiofolders/" "/shared/shortcuts/" "/playlists/" )

# Folder on your Remote Target without the last /
remote_target="/share/Public/Phoniebox/Backup"

# Remote User Name
remote_user="root"

# Remote FQDN or IP-Adress
remote_server="192.168.0.1"

######################################################################################


# Some Constants, don't change them
NOCOLOR='\e[0m'
RED="\e[1;91m"
CYAN="\e[1;36m"
YELLOW="\e[1;93m"
GREEN="\e[1;92m"

function sync_data() {
        #$1 = local Folder
        #$2 = Remote Folder
        #$3 = remote_server
        #$4 = User
	echo -e "  → Local Sync Folder:     ${CYAN}$1${NOCOLOR}"
        echo -e "  → Remote Sync Folder:    ${CYAN}$2${NOCOLOR}"
        echo -e ""
        echo -e "  → Sync Direction:        ${CYAN}$3${NOCOLOR} --> local Pi"
        echo -e -n "  → Sync-Progess:"

        if ssh -q ${4}@${3} [[ -d $2 ]]
        then
                rsync -az ${4}@${3}:${2} ${1}
                echo -e "${GREEN}          Done${NOCOLOR}"
        else
                echo -e "${YELLOW}          Skipped - Folder does not exist${NOCOLOR}"
		ssh -q ${4}@${3} mkdir -p $2 > /dev/null
		echo -e "  → Remote Folder/s:       ${GREEN}Created${NOCOLOR}"
        fi
        echo -e ""
        echo -e "  → Sync Direction:        local Pi --> ${CYAN}$3${NOCOLOR}"
        echo -e -n "  → Sync-Progess:"
        rsync -az ${1} ${4}@${3}:${2}
        echo -e "${GREEN}          Done${NOCOLOR}"
        echo -e "───────────────────────────────────────────────────────────────────────────────────────────────"
}

server_online=`ping -c 1 $remote_server | grep packet | awk '{print $4}'`

echo -e "───────────────────────────────────────────────────────────────────────────────────────────────"
if [ $server_online == 1 ]; then
	echo -e "  → Remote Server Status:  ${GREEN}Online${NOCOLOR}"
	echo -e "───────────────────────────────────────────────────────────────────────────────────────────────"
	for dir in "${sync_dirs[@]}"; do sync_data "${phoniebox_folder}${dir}" "${remote_target}${dir}" "${remote_server}" "${remote_user}"; done
else
        echo -e "  → Remote Server Status:  ${RED}Offline${NOCOLOR}"
        echo -e "  → ${YELLOW}>>> Skipping Sync Progress <<<${NOCOLOR}"
        echo -e "───────────────────────────────────────────────────────────────────────────────────────────────"
fi


echo -e "  → Scan Music Libary:     "
sudo service mopidy stop > /dev/null
sudo mopidyctl local scan  > /dev/null
sudo service mopidy start  > /dev/null
echo -e "${GREEN}Done${NOCOLOR}"
echo -e "───────────────────────────────────────H─A─V─E───F─U─N─────────────────────────────────────────"
