#!/usr/bin/env bash

# Auto-heal any demo environemnts.  Expects a parameter of the 
#  system that should be monitored

if [[ -n '$1' ]]; then
  Demohost=$1
else
  echo "Please specify host as first parameter"
  exit 1
fi

if [[ -n '$2' ]]; then
  servicepwd=$2
else
  echo "Please service password for second parameter"
  exit 1
fi


timestamp=`date "+%Y.%m.%d %H:%M:%S"`

function check_restart_service () {
    emailed="@EMAIL.com"
    reboott=$((3600)) 
    
    #Check if the redirect page is broken
    text=$(curl -s -k -m 20 "https://$Demohost/ui/login.action")
    string="Authentication Source:"
    if [[ $text == *"$string"* ]]; then
        echo "'$string' found"
        #Check passed
    else
        #Check Failure. Reboot box
        #echo "'$string' not found in text:"
        #echo "$text"
        echo  "$Demohost is Restarting Web service now: Redirect Page Not Working"
        logger -p local0.info "$Demohost is restarting web services Reason: Auth page not working (check_restart_service)" 
        ssh root@$Demohost "service vmware-vcops-web restart && exit"
	return 0
    fi
    
    #check if it has been an hour before last reboot 
    utime=$(ssh -q root@$Demohost "awk '{ print \$1 }' /proc/uptime | cut -f1 -d.")
    if [[ "${utime}" -le "${reboott}" ]]; then
        return 0
    fi

    #Check if the data retriever is not yet initialized
    text=$(curl -s -k -u admin:${servicepwd} "https://$Demohost/casa/stats/counts")
    string=":-1.0"
    if [[ $text == *"$string"* ]]; then
        #Check failure, reboot box
        #echo "'$string' found"
        echo "$Demohost is rebooting now Reason: Data Retreiver Not Yet Initialized" 
        logger -p local0.info "$Demohost is rebooting now Reason: Redirect Page Not Working (check_restart_service)" 
        ssh root@$Demohost "/sbin/reboot && exit"
        return 0
    else
        #Check passed.
        logger -p local0.info "$Demohost is OK (check_restart_service)" 
        #echo "'$string' not found in text:"
        #echo "$text"
    fi
}

function check_restart_os () {
        reboott=$((3600))
        #check if it has been an hour before last reboot
        utime=$(ssh -q root@$Demohost "awk '{ print \$1 }' /proc/uptime | cut -f1 -d.")
        if [[ "${utime}" -le "${reboott}" ]]; then
           return 0
        fi
        text2=$(curl -s -k -m 20 "https://$Demohost/ui/login.action")
        string2="Authentication Source:"
        if [[ $text2 == *"$string2"* ]]; then
            logger -p local0.info "$Demohost is OK (check_restart_os)" 
            echo "'$string' found"
            #Check passed
        else
            logger -p local0.info "$Demohost is rebooting now Reason: Redirect Page Not Working (check_restart_os)" 
            ssh root@$Demohost "/sbin/reboot && exit"
            return 0
        fi
}

#
# MAIN Section
#

check_restart_service
check_restart_os
