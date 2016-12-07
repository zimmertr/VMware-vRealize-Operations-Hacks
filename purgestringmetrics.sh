#!/bin/bash
echo "Shutting down vROps services..."
service vmware-vcops stop collector >> /dev/null
service vmware-vcops stop analytics >> /dev/null

echo && echo "Purging string metrics..."
touch /root/cassandra.cql
echo 'use globalpersistence;' >> /root/cassandra.cql
echo 'consistency all;' >> /root/cassandra.cql
echo 'truncate property_string_to_id_mapping;' >> /root/cassandra.cql
$VCOPS_BASE/cassandra/apache-cassandra-2.1.8/bin/cqlsh --ssl --cqlshrc $VCOPS_BASE/user/conf/cassandra/cqlshrc -f /root/cassandra.cql >> /dev/null
rm /root/cassandra.cql

echo && echo "String Metrics have been purged. Rebooting in 10 seconds..."
sleep 10
reboot
