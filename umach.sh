#!/bin/bash

# MAC changer for Ubuntu Touch
# NetworkManager 1.2.2
# Author ilvs
# Mail ilia@ilvs.ru
# License GNU GPLv3

if [[ "$EUID" -ne 0 ]]; then echo "Run it as root"; exit 0; fi 

info() {
    echo "Use: umach.sh r/m/l <ssid> [mac]"
    echo "Random MAC: umach.sh r <ssid>"
    echo "Manual MAC: umach.sh m <ssid> <mac>"
    echo "SSID list:  umach.sh l" 
}

is_mac() {
    output="^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$"
    if [[ $1 =~ $output ]]; then
        echo 1
    else 
        echo 0
    fi
}

restart() {
    echo "Do you want to restart NetworkManager right now? (Y/n): "
    read answer
    if [[ ${answer^^} -eq "Y" ]]; then 
        service network-manager restart
    fi
}


case $1 in

    l) 
        echo "$(ls /etc/NetworkManager/system-connections/)"
    ;;

    m)
        if ! [[ $2 && $3 ]]; then echo "Use umach.sh m $2 <mac>"; exit 0; fi

        if ! [[ -a /etc/NetworkManager/system-connections/$2 ]]; then echo "SSID $2 does not exists :p"; exit 0; fi

        if [[ $(is_mac "$3") == 1 ]]; then
            nmcli c mod $2 wifi.cloned-mac-address $3
            echo "Now $2 should have $3 cloned-mac-address."
            restart
        else
            echo "MAC is invalid"
        fi

    ;;

    r) 
        if ! [[ $2 ]]; then info; exit 0; fi
        NEW_MAC=$(printf '%02X:%02X:%02X:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])
        if [[ -a /etc/NetworkManager/system-connections/$2 ]]; then
            nmcli c mod $2 wifi.cloned-mac-address ${NEW_MAC}
            echo "Now $2 should have ${NEW_MAC} cloned-mac-address."
            restart
        else
            echo "SSID $2 does not exists :p"
        fi
    ;;

    *)
        info
    ;;

esac