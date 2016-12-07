#!/bin/bash
####################################################################################################
#This script is intended to automagically convert an instance of vROps 6.2.1 from normal mode to   #
#Historical View Mode (HVM). In addition to modifying the system date and relevant config          #
#directives to enter HVM, it also does several other things that increase the qualify, performance #
#and speed of vROps in HVM. It accepts two parameters (HVM Start Time and the Time Interval). A    #
#cronjob to maintain vROps place in HVM is generated, it disables NTP to prevent vROps from        #
#removing itself from HVM, and it bumps the capacity interval up from once per 24 hours to a every #
#15 minutes.                                                                                       #
####################################################################################################
#Date passed to this script must be formatted as follows: MM/DD/YYY HH:MM and the interval time    #
#must be a positve integer value. Example: ./setdate.sh '06/30/2016 14:30' 30  will place the box  #
#into HVM between the period of 2:30PM and 3:00PM on the 30th of June, 2016. Time provided to this #
#script should be provided in UTC as vROps natively runs in UTC at the system level.               #
####################################################################################################

#Pass parameters to variables
startTime=$1
collectionInterval=$2

#If setdate script doesn't exist, create it, add logic, and add a crontask. Advance the script to 
#runlevel three so that it is called sooner, disable NTP so that vROps doesn't remove itself from 
#HVM, and advance the capacity collection interval from once every 24 hours to once every 15 minutes.
if [ ! -f /root/setdate.sh ]; then
    touch /root/setdate.sh
    chmod +x /root/setdate.sh

    echo "#!/bin/bash" >> /root/setdate.sh
    echo "date=\"$startTime\"" >> /root/setdate.sh
    echo "date --set=\"$startTime\"" >> /root/setdate.sh
    echo "*/${collectionInterval} * * * * /root/setdate.sh" | crontab -u root -
    chmod +x /root/setdate.sh

    #Bump script up to a higher runlevel so it starts sooner.
    ln -sv /root/setdate.sh /etc/init.d/rc3.d/S09setdate >> /dev/null

    #Disable problematic services
	chkconfig ntp off >> /dev/null
	service ntp stop >> /dev/null
	mv /usr/sbin/ntpd ~

#If it does exist, simply modify it with the new time.
else
    awk 'NR!~/^(2|3)$/' /root/setdate.sh >> /root/setdate.sh.tmp && mv /root/setdate.sh.tmp /root/setdate.sh
    echo "date=\"$startTime\"" >> /root/setdate.sh
    echo "date --set=\"$startTime\"" >> /root/setdate.sh

    crontab -r >> /dev/null
    echo "*/${collectionInterval} * * * * /root/setdate.sh" | crontab -u root -
fi

#Take cluster offline so that the node can be placed in HVM.
$VMWARE_PYTHON_BIN /usr/lib/vmware-vcopssuite/utilities/sliceConfiguration/bin/vcopsConfigureRoles.py --action bringSliceOffline --offlineReason enablingHVM >> /dev/null

#Move existing log files. Sometimes log files can cause issues when a historical time is provided and the log files are newer than the system.
#rm /usr/lib/vmware-vcops/user/log/*.log*

#Sleep to wait for node to shutdown completely.
sleep 60

#Enable HVM
sed -i s/historicalViewModeEnabled=.*/historicalViewModeEnabled=true/g /usr/lib/vmware-vcops/user/conf/analytics/advanced.properties
sed -i "s%historicalViewTime=.*%historicalViewTime=${startTime}%g" /usr/lib/vmware-vcops/user/conf/analytics/advanced.properties
sed -i s/historicalViewGoBackTime=.*/historicalViewGoBackTime=${collectionInterval}/g /usr/lib/vmware-vcops/user/conf/analytics/advanced.properties
sed -i s/historicalLoadAllResources=.*/historicalLoadAllResources=false/g /usr/lib/vmware-vcops/user/conf/analytics/advanced.properties
date --set="$startTime" >> /dev/null

#Bring cluster back online
$VMWARE_PYTHON_BIN /usr/lib/vmware-vcopssuite/utilities/sliceConfiguration/bin/vcopsConfigureRoles.py --action bringSliceOnline >> /dev/null
