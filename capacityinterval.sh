#!/bin/bash

#Speed up the capacity collection period.

$VMWARE_PYTHON_BIN /usr/lib/vmware-vcopssuite/utilities/sliceConfiguration/bin/vcopsConfigureRoles.py --action bringSliceOffline --offlineReason shorteningCapacities >> /dev/null
sed -i s/capacityComputationStartTime=.*/capacityComputationStartTime=-5/g /usr/lib/vmware-vcops/user/conf/analytics/capacity.properties
sed -i s/capacityComputationPeriod=.*/capacityComputationPeriod=5/g /usr/lib/vmware-vcops/user/conf/analytics/capacity.properties
sed -i s/capacityPrecomputationDelay=.*/capacityPrecomputationDelay=1/g /usr/lib/vmware-vcops/user/conf/analytics/capacity.properties
sed -i s/capacityPrecomputationPeriod=.*/capacityPrecomputationPeriod=5/g /usr/lib/vmware-vcops/user/conf/analytics/capacity.properties
sed -i s/precomputationRange=.*/precomputationRange=1/g /usr/lib/vmware-vcops/user/conf/analytics/capacity.properties
$VMWARE_PYTHON_BIN /usr/lib/vmware-vcopssuite/utilities/sliceConfiguration/bin/vcopsConfigureRoles.py --action bringSliceOnline >> /dev/null
