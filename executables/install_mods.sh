#!/bin/bash

## Mod Downloader ARMA 3
# Made by: Jeroen Vijgen (BlackChaosNL)

# Use: steamworkshopdownloader.io for workshop IDs!

STEAM_ACCT_USERNAME="{steam account with ARMA 3 BOUGHT!}"
ARMA3_ID=107410

# Fill these two arrays with the mods of choosing. Make sure the mod names are correct.
MOD_NAMES=("@antistasi")
MODS=(2867537125)

function workshop_download () {
    steamcmd +login $STEAM_ACCT_USERNAME +workshop_download_item $ARMA3_ID $1 validate +quit
};

# Check if target folder is not available or clean it and (re)fill it.
# TODO: Add PWD to execute in current folder, not absolute paths.
function move_workshop_item () {
    if [ ! -d /app/serverfiles/mods/$2 ]; then
        mkdir /app/serverfiles/mods/$2
    else
        # Clean old stuff up.
        rm -r /app/serverfiles/mods/$2
        mkdir /app/serverfiles/mods/$2
    fi
    # Move new mod data into appropriate folders.
    cp -r /data/.local/share/Steam/steamapps/workshop/content/$ARMA3_ID/$1/* /app/serverfiles/mods/$2
    rm -r /data/.local/share/Steam/steamapps/workshop/* # Fix Queue not Empty: epochmod.com/forum/topic/42074-fixed-steamcmd-queue-not-empty/
};

# If any mod name contains any uppercase character, clean it, since arma cannot deal with this.
function check_and_fix_depth () {
    local depth=0
    for x in $(find . -type d | sed "s/[^/]//g"); do
    if [ ${depth} -lt ${#x} ]; then
        depth=${#x}
    fi
    done

    for ((i=1;i<=${depth};i++)); do
        for x in $(find . -maxdepth $i | grep [A-Z]); do
            mv $x $(echo $x | tr 'A-Z' 'a-z' )
        done
    done
};

function apply_mod_signing_keys_to_server () {
    for dir in Keys keys Key key; do
        if [ -d /app/serverfiles/mods/$1/$dir ]; then
            cp -r /app/serverfiles/mods/$1/$dir/*.bikey /app/serverfiles/keys/
        fi
    done
};

function remove_mod_signing_keys_from_server () {
    pushd $(pwd)
    cd /app/serverfiles/keys/
    find . ! -name a3.bikey -maxdepth 1 -type f -delete
    popd
};

function check_mod_names_and_mods_array_lengths () {
    local -n array1="$1"
    local -n array2="$2"

    if [[ ! ${#array1[@]} -eq ${#array2[@]} ]]; then
        echo "Arrays MOD_NAMES and MODS are not correctly filled, please check."
        exit 1
    fi
};

function replace_mods_value () {
    local -n MOD_ARRAY=$1
    local LINUXGSM_SERVER_CONFIG="/app/lgsm/config-lgsm/arma3server/arma3server.cfg"
    local MOD_LIST=""

    if [[ ! -e "$LINUXGSM_SERVER_CONFIG" ]]; then
        echo "Error: File $LINUXGSM_SERVER_CONFIG does not exist."
        return 1
    fi

    for mod in "${MOD_ARRAY[@]}"; do
        MOD_LIST+="mods/${mod}\;"
    done

    # Use sed to find the line and replace the current value of mods with the new string
    sed -i "s/^mods=\"[^\"]*\"/mods=\"$MOD_LIST\"/" "$LINUXGSM_SERVER_CONFIG"

    echo "The mods value has been updated in $LINUXGSM_SERVER_CONFIG."
};

function start () {
    local counter=1
    local maxtries=5
    check_mod_names_and_mods_array_lengths ${MOD_NAMES} ${MODS}
    remove_mod_signing_keys_from_server
    steamcmd +login $STEAM_ACCT_USERNAME +quit # buffer steam login for mod download and update!
    for i in ${!MODS[*]}; do
        until workshop_download ${MODS[$i]}; do
            echo "Error downloading ${MOD_NAMES[$i]}... Try ${counter}/${maxtries}"
            counter=$((counter + 1))
            if [ $counter -ge $maxtries ]; then
                echo "Mod ${MOD_NAMES[$i]} has not downloaded, check steamcmd stderr.txt: /data/.local/share/Steam/logs/stderr.txt"
                exit 1;
            fi
        done
        move_workshop_item ${MODS[$i]} ${MOD_NAMES[$i]}
        apply_mod_signing_keys_to_server ${MOD_NAMES[$i]}
        sleep 5 # Prevent downloading too fast and getting rate limited.
    done
    check_and_fix_depth
    replace_mods_value ${MODS}
    echo "Thank you for using Mod Downloader!"
};

start
