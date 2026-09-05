#!/bin/bash

SYSTEMIP1="matsya-vagvbox-sa-kfk-192-168-1-50.local"
SYSTEMIP2="matsya-vagvbox-sa-kfk-192-168-1-51.local"
SYSTEMIP3="matsya-vagvbox-sa-kfk-192-168-1-52.local"
SYSTEMIP4="matsya-vagvbox-sa-kfk-192-168-1-53.local"
SYSTEMIP5="matsya-vagvbox-sa-kfk-192-168-1-54.local"

THEHOSTNAME=$(hostname)

sudo service firewalld stop

kill $(ps aux | grep '[z]ookeeper.properties' | awk '{print $2}')
kill $(ps aux | grep '[s]erver.properties' | awk '{print $2}')
kill $(ps aux | grep '[s]chema-registry.properties' | awk '{print $2}')
kill $(ps aux | grep '[c]onnect-avro-distributed.properties' | awk '{print $2}')
kill $(ps aux | grep '[k]afka-rest.properties' | awk '{print $2}')
kill $(ps aux | grep '[k]sql-server.properties' | awk '{print $2}')
kill $(ps aux | grep '[c]ontrol-center-minimal.properties' | awk '{print $2}')

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ]; then
	sudo systemctl start kafka-zookeeper
	sleep 5
fi

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ] || [ $THEHOSTNAME == "$SYSTEMIP4" ] ; then
	sudo systemctl start kafka-broker	
fi

if [ "$THEHOSTNAME" == "$SYSTEMIP5" ] ; then
	sudo systemctl start kafka-schema-registry
	sleep 5
	sudo systemctl start kafka-connect
	sleep 5
	sudo systemctl start kafka-rest
	sleep 5
	sudo systemctl start kafka-ksql-server
	sleep 5
	sudo systemctl start kafka-control-center	 		
fi

