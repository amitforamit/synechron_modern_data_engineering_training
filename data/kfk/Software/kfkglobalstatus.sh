#!/bin/bash

SYSTEMIP1="matsya-vagvbox-sa-kfk-192-168-1-50.local"
SYSTEMIP2="matsya-vagvbox-sa-kfk-192-168-1-51.local"
SYSTEMIP3="matsya-vagvbox-sa-kfk-192-168-1-52.local"
SYSTEMIP4="matsya-vagvbox-sa-kfk-192-168-1-53.local"
SYSTEMIP5="matsya-vagvbox-sa-kfk-192-168-1-54.local"

THEHOSTNAME=$(hostname)

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ]; then
	sudo systemctl status kafka-zookeeper
fi

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ] || [ $THEHOSTNAME == "$SYSTEMIP4" ] ; then
	sudo systemctl status kafka-broker	
fi

if [ "$THEHOSTNAME" == "$SYSTEMIP5" ] ; then
	sudo systemctl status kafka-schema-registry
	sudo systemctl status kafka-connect
	sudo systemctl status kafka-rest
	sudo systemctl status kafka-ksql-server
	sudo systemctl status kafka-control-center	 		
fi

