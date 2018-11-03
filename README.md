# VMware vRealize Operations Manager Hacks

This repository is a collection of several scripts that I wrote to hack/modify vROps. All scripts are tested and work on vROps 6.2, 6.3, and 6.4. 

## enterhvm.sh

This script is intended to automagically convert an instance of vROps from normal mode to Historical View Mode (HVM). In addition to modifying the system date and relevant config directives to enter HVM, it also does several other things that increase the qualify, performance and speed of vROps in HVM. It accepts two parameters (HVM Start Time and the Time Interval). A cronjob to maintain vROps place in HVM is generated, it disables NTP to prevent vROps from removing itself from HVM, and it bumps the capacity interval up from once per 24 hours to a every 15 minutes.    

Date passed to this script must be formatted as follows: MM/DD/YYY HH:MM and the interval time must be a positve integer value. Example: ./setdate.sh '06/30/2016 14:30' 30  will place the box into HVM between the period of 2:30PM and 3:00PM on the 30th of June, 2016. Time provided to this script should be provided in UTC as vROps natively runs in UTC at the system level.  


## capacityinterval.sh

This script is intended to advance the amount of time required to generate capacity metrics in vROps. This is useful when trying to create a vROps demo environment within a 24 hour timeframe where you can't wait for capacities to be automatically generated. vROps automatically generates capacities once per 24 hours. And there is an ability to customize this value from within Global Settings. However, when doing so, you can only specify on-the-hour times. This script allows you to set the interval to anytime you want, including just every 5 minutes.

## autoheal.sh

This script will check on two of the driving services behind a vROps instance, vmware-vcops-web and vmware-casa. If either of them are in an unusual state, it will attempt to restart their respective service to heal them. In the event that this doesn't work, the specific node is rebooted. This is meant to work with a load balanced instance of a vROps demo environments comprised of many nodes. In a situation where there is only one node, this could cause downtime and is not recommended. 

## purgestringmetrics.sh

Some versions of vROps suffer from a bug that causes string metrics to be generated en masse in the Cassandra database. When this occurs, performance will seriously deteriate and the platform will become unstable. This script enters the Cassandra database, retrieves all of the string metrics, and purges them.
