#!/bin/bash

# ===============================================================================================
# Component			Port			Original Port
# ===============================================================================================
# ZooKeeper			3100,3200,3300		2181,2888,3888
# Kafka brokers (plain text)	3400			9092
# Schema Registry REST API	3500			8081
# Kafka Connect REST API	3600			8083
# REST Proxy			3700			8082
# KSQL Server REST API		3800			8088
# Metadata Service (MDS)	3900			8090
# Confluent Control Center	4000			9021
# ZooNavigator			4100,4200
# Kafka-Manager (CMAK)		4210
# Kafka-Monitor			8778
# Kafka JMX Exporter		4215			8080
# 				4220			8080
# Prometheus			4230			9090
# Grafana			4240			3000
# ===============================================================================================
# Confluent Control Center	http://matsya-vagvbox-sa-kfk-192-168-1-54.local:4000
# ZooNavigator			http://matsya-vagvbox-sa-kfk-192-168-1-54.local:4200
# Kafka-Manager			http://matsya-vagvbox-sa-kfk-192-168-1-54.local:4210
# Kafka-Monitor			http://matsya-vagvbox-sa-kfk-192-168-1-54.local:8778/jolokia/read/kmf.services:type=produce-service,name=*/produce-availability-avg
# Kafka JMX Exporter		http://matsya-vagvbox-sa-kfk-192-168-1-50.local:4215
#				http://matsya-vagvbox-sa-kfk-192-168-1-51.local:4215
#				http://matsya-vagvbox-sa-kfk-192-168-1-52.local:4215
#				http://matsya-vagvbox-sa-kfk-192-168-1-50.local:4220
#				http://matsya-vagvbox-sa-kfk-192-168-1-51.local:4220
#				http://matsya-vagvbox-sa-kfk-192-168-1-52.local:4220
#				http://matsya-vagvbox-sa-kfk-192-168-1-53.local:4220
# Prometheus			http://matsya-vagvbox-sa-kfk-192-168-1-54.local:4230
# Grafana			http://matsya-vagvbox-sa-kfk-192-168-1-54.local:4240
#				(Default Prometheus Based Kafka Dashboard No 721)
# ===============================================================================================
# nano /work/kafka/confluent-6.1.1/etc/kafka/zookeeper.properties
# nano /work/kafka/confluent-6.1.1/etc/kafka/server.properties
# nano /work/kafka/confluent-6.1.1/etc/schema-registry/schema-registry.properties
# nano /work/kafka/confluent-6.1.1/etc/kafka/connect-distributed.properties
# nano /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
# nano /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
# nano /work/kafka/confluent-6.1.1/etc/ksqldb/ksql-server.properties
# nano /work/kafka/confluent-6.1.1/etc/ksqldb/connect.properties
# nano /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
# nano /work/kafka/monitor/config/xinfra-monitor.properties
# nano /work/kafka/prometheus/core/prometheus.yml
# nano /work/kafka/prometheus/grafana/conf/defaults.ini
# ===============================================================================================
# sudo systemctl status kafka-zookeeper
# sudo systemctl status kafka-broker
# sudo systemctl status kafka-schema-registry
# sudo systemctl status kafka-connect
# sudo systemctl status kafka-rest
# sudo systemctl status kafka-ksql-server
# sudo systemctl status kafka-control-center
# sudo systemctl status docker-compose@zoonavigator
# sudo systemctl status docker-compose@kafka-manager
# sudo systemctl status kafka-monitor
# sudo systemctl status kafka-prometheus
# sudo systemctl status kafka-grafana
# ===============================================================================================

SYSTEMIP1="matsya-vagvbox-sa-kfk-192-168-1-50.local"
SYSTEMIP2="matsya-vagvbox-sa-kfk-192-168-1-51.local"
SYSTEMIP3="matsya-vagvbox-sa-kfk-192-168-1-52.local"
SYSTEMIP4="matsya-vagvbox-sa-kfk-192-168-1-53.local"
SYSTEMIP5="matsya-vagvbox-sa-kfk-192-168-1-54.local"

THEHOSTNAME=$(hostname)
THEUSERNAME=$(whoami)
THEUSERDIR=$(pwd)

sudo service firewalld stop
sudo usermod -a -G docker $THEUSERNAME
sudo yum install docker-compose git python-pip -y

kill $(ps aux | grep '[z]ookeeper.properties' | awk '{print $2}')
kill $(ps aux | grep '[s]erver.properties' | awk '{print $2}')
kill $(ps aux | grep '[s]chema-registry.properties' | awk '{print $2}')
kill $(ps aux | grep '[c]onnect-avro-distributed.properties' | awk '{print $2}')
kill $(ps aux | grep '[k]afka-rest.properties' | awk '{print $2}')
kill $(ps aux | grep '[k]sql-server.properties' | awk '{print $2}')
kill $(ps aux | grep '[c]ontrol-center-minimal.properties' | awk '{print $2}')

sudo systemctl stop kafka-zookeeper && sudo systemctl disable kafka-zookeeper
sudo systemctl stop kafka-broker && sudo systemctl disable kafka-broker
sudo systemctl stop kafka-schema-registry && sudo systemctl disable kafka-schema-registry
sudo systemctl stop kafka-connect && sudo systemctl disable kafka-connect
sudo systemctl stop kafka-rest && sudo systemctl disable kafka-rest
sudo systemctl stop kafka-ksql-server && sudo systemctl disable kafka-ksql-server
sudo systemctl stop kafka-control-center && sudo systemctl disable kafka-control-center
sudo systemctl stop kafka-monitor && sudo systemctl disable kafka-monitor
sudo systemctl stop kafka-prometheus && sudo systemctl disable kafka-prometheus
sudo systemctl stop kafka-grafana && sudo systemctl disable kafka-grafana

sudo rm -rf /etc/systemd/system/kafka-zookeeper.service
sudo rm -rf /etc/systemd/system/kafka-broker.service
sudo rm -rf /etc/systemd/system/kafka-schema-registry.service
sudo rm -rf /etc/systemd/system/kafka-connect.service
sudo rm -rf /etc/systemd/system/kafka-rest.service
sudo rm -rf /etc/systemd/system/kafka-ksql-server.service
sudo rm -rf /etc/systemd/system/kafka-control-center.service
sudo rm -rf /etc/systemd/system/kafka-monitor.service
sudo rm -rf /etc/systemd/system/kafka-prometheus.service
sudo rm -rf /etc/systemd/system/kafka-grafana.service

echo "[Unit]
Description=Kafka ZooKeeper
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
Environment=\"EXTRA_ARGS=-javaagent:/work/kafka/prometheus/jmx_prometheus_javaagent-0.15.0.jar=4215:/work/kafka/prometheus/zookeeper.yaml\"
ExecStart=/work/kafka/confluent-6.1.1/bin/zookeeper-server-start /work/kafka/confluent-6.1.1/etc/kafka/zookeeper.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-zookeeper.service > /dev/null
	
echo "[Unit]
Description=Kafka Broker
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
Environment=\"KAFKA_OPTS=-javaagent:/work/kafka/prometheus/jmx_prometheus_javaagent-0.15.0.jar=4220:/work/kafka/prometheus/kafka-0-8-2.yml\"
ExecStart=/work/kafka/confluent-6.1.1/bin/kafka-server-start /work/kafka/confluent-6.1.1/etc/kafka/server.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-broker.service > /dev/null

echo "[Unit]
Description=Kafka Schema Registry
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
ExecStart=/work/kafka/confluent-6.1.1/bin/schema-registry-start /work/kafka/confluent-6.1.1/etc/schema-registry/schema-registry.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-schema-registry.service > /dev/null

echo "[Unit]
Description=Kafka Connect
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
ExecStart=/work/kafka/confluent-6.1.1/bin/connect-distributed /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-connect.service > /dev/null

echo "[Unit]
Description=Kafka REST API
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
ExecStart=/work/kafka/confluent-6.1.1/bin/kafka-rest-start /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-rest.service > /dev/null

echo "[Unit]
Description=Kafka KSQL
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
ExecStart=/work/kafka/confluent-6.1.1/bin/ksql-server-start /work/kafka/confluent-6.1.1/etc/ksqldb/ksql-server.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-ksql-server.service > /dev/null

echo "[Unit]
Description=Kafka Control Center
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
ExecStart=/work/kafka/confluent-6.1.1/bin/control-center-start /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-control-center.service > /dev/null

echo "[Unit]
Description=Kafka Monitor
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
ExecStart=/work/kafka/monitor/bin/xinfra-monitor-start.sh /work/kafka/monitor/config/xinfra-monitor.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-monitor.service > /dev/null

echo "[Unit]
Description=Kafka Prometheus
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=$THEUSERDIR
ExecStart=/work/kafka/prometheus/core/prometheus --config.file=/work/kafka/prometheus/core/prometheus.yml --web.enable-admin-api --web.listen-address=:4230 --storage.tsdb.path=/work/kafka/prometheus/core/data
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-prometheus.service > /dev/null

echo "[Unit]
Description=Kafka Grafana
After=network.target

[Service]
User=$THEUSERNAME
Group=$THEUSERNAME
WorkingDirectory=/work/kafka/prometheus/grafana
ExecStart=/work/kafka/prometheus/grafana/bin/grafana-server
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/kafka-grafana.service > /dev/null

sudo rm -rf /etc/systemd/system/docker-compose@.service
sudo mkdir -p /etc/docker/compose
echo "# /etc/systemd/system/docker-compose@.service
# From: https://github.com/docker/compose/issues/4266#issuecomment-302813256
[Unit]
Description=%i service with docker compose
Requires=docker.service
After=docker.service

[Service]
Restart=always

WorkingDirectory=/etc/docker/compose/%i

# Remove old containers, images and volumes
ExecStartPre=/usr/bin/docker-compose down -v
ExecStartPre=/usr/bin/docker-compose rm -fv
ExecStartPre=-/bin/bash -c 'docker volume ls -qf \"name=%i_\" | xargs docker volume rm'
ExecStartPre=-/bin/bash -c 'docker network ls -qf \"name=%i_\" | xargs docker network rm'
ExecStartPre=-/bin/bash -c 'docker ps -aqf \"name=%i_*\" | xargs docker rm'

# Compose up
ExecStart=/usr/bin/docker-compose up

# Compose down, remove containers and volumes
ExecStop=/usr/bin/docker-compose down -v

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/docker-compose@.service > /dev/null

sudo systemctl daemon-reload

sudo rm -rf /work
sudo mkdir -p /work/kafka/zk
sudo mkdir -p /work/kafka/kfk
sudo chmod -R 777 /work 
cp confluent-6.1.1.zip /work/kafka
pushd /work/kafka
unzip -qq confluent-6.1.1.zip 
rm -f confluent-6.1.1.zip 
popd
rm -rf /work/kafka/zk/*
rm -rf /work/kafka/kfk/*
rm -rf /work/kafka/confluent-6.1.1/logs/*
sudo chmod -R 777 /work

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ] || [ $THEHOSTNAME == "$SYSTEMIP4" ] ; then
	sed -i -e "s~zookeeper.connect=localhost:2181~zookeeper.connect=$SYSTEMIP1:3100,$SYSTEMIP2:3100,$SYSTEMIP3:3100~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	sed -i -e "s~log.dirs=/tmp/kafka-logs~log.dirs=/work/kafka/kfk~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	sed -i -e "s~#metric.reporters=io.confluent.metrics.reporter.ConfluentMetricsReporter~metric.reporters=io.confluent.metrics.reporter.ConfluentMetricsReporter~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	sed -i -e "s~#confluent.metrics.reporter.bootstrap.servers=localhost:9092~confluent.metrics.reporter.bootstrap.servers=$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	echo "confluent.schema.registry.url=http://$SYSTEMIP5:3500" >> /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	sed -i -e "s~#listeners=PLAINTEXT://:9092~listeners=PLAINTEXT://$THEHOSTNAME:3400~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	sed -i -e "s~offsets.topic.replication.factor=1~offsets.topic.replication.factor=3~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	sed -i -e "s~transaction.state.log.replication.factor=1~transaction.state.log.replication.factor=3~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
	sed -i -e "s~transaction.state.log.min.isr=1~transaction.state.log.min.isr=2~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties	
fi

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ]; then
	rm -f /work/kafka/confluent-6.1.1/etc/kafka/zookeeper.properties
	echo "tickTime=2000
dataDir=/work/kafka/zk
clientPort=3100
initLimit=5
syncLimit=2
server.1=$SYSTEMIP1:3200:3300
server.2=$SYSTEMIP2:3200:3300
server.3=$SYSTEMIP3:3200:3300
autopurge.snapRetainCount=3
autopurge.purgeInterval=24
maxClientCnxns=0" >> /work/kafka/confluent-6.1.1/etc/kafka/zookeeper.properties
fi

if [ "$THEHOSTNAME" == "$SYSTEMIP1" ] ; then
	echo "1" >> /work/kafka/zk/myid
	sed -i -e "s~broker.id=0~broker.id=100~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
fi
if [ "$THEHOSTNAME" == "$SYSTEMIP2" ] ; then
	echo "2" >> /work/kafka/zk/myid
	sed -i -e "s~broker.id=0~broker.id=200~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
fi
if [ "$THEHOSTNAME" == "$SYSTEMIP3" ] ; then
	echo "3" >> /work/kafka/zk/myid
	sed -i -e "s~broker.id=0~broker.id=300~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
fi
if [ "$THEHOSTNAME" == "$SYSTEMIP4" ] ; then
	sed -i -e "s~broker.id=0~broker.id=400~g" /work/kafka/confluent-6.1.1/etc/kafka/server.properties
fi

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ] || [ $THEHOSTNAME == "$SYSTEMIP4" ] ; then
	sudo mkdir -p /work/kafka/prometheus
	sudo rm -rf /work/kafka/prometheus/*
	cd ~	
	sudo cp jmx_prometheus_javaagent-0.15.0.jar /work/kafka/prometheus
	sudo cp kafka-0-8-2.yml /work/kafka/prometheus
	sudo cp zookeeper.yaml /work/kafka/prometheus
	sudo chmod -R 777 /work
fi

if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ]; then
	sudo systemctl enable kafka-zookeeper && sudo systemctl start kafka-zookeeper
fi
if [ $THEHOSTNAME == "$SYSTEMIP1" ] || [ $THEHOSTNAME == "$SYSTEMIP2" ] || [ $THEHOSTNAME == "$SYSTEMIP3" ] || [ $THEHOSTNAME == "$SYSTEMIP4" ] ; then
	sudo systemctl enable kafka-broker && sudo systemctl start kafka-broker
fi

if [ "$THEHOSTNAME" == "$SYSTEMIP5" ] ; then
	sed -i -e "s~listeners=http://0.0.0.0:8081~listeners=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/schema-registry/schema-registry.properties
	sed -i -e "s~#kafkastore.connection.url=localhost:2181~kafkastore.connection.url=$SYSTEMIP1:3100,$SYSTEMIP2:3100,$SYSTEMIP3:3100~g" /work/kafka/confluent-6.1.1/etc/schema-registry/schema-registry.properties
	sed -i -e "s~kafkastore.bootstrap.servers=PLAINTEXT://localhost:9092~#kafkastore.bootstrap.servers=PLAINTEXT://localhost:9092~g" /work/kafka/confluent-6.1.1/etc/schema-registry/schema-registry.properties

	sed -i -e "s~bootstrap.servers=localhost:9092~bootstrap.servers=$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/confluent-6.1.1/etc/kafka/connect-distributed.properties
	sed -i -e "s~#rest.host.name=~rest.host.name=$SYSTEMIP5~g" /work/kafka/confluent-6.1.1/etc/kafka/connect-distributed.properties
	sed -i -e "s~#rest.port=8083~rest.port=3600~g" /work/kafka/confluent-6.1.1/etc/kafka/connect-distributed.properties
	echo "consumer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor" >> /work/kafka/confluent-6.1.1/etc/kafka/connect-distributed.properties
	echo "producer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor" >> /work/kafka/confluent-6.1.1/etc/kafka/connect-distributed.properties

	sed -i -e "s~bootstrap.servers=localhost:9092~bootstrap.servers=$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
	sed -i -e "s~#rest.host.name=0.0.0.0~rest.host.name=$SYSTEMIP5~g" /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
	sed -i -e "s~#rest.port=8083~rest.port=3600~g" /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
	echo "consumer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor" >> /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
	echo "producer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor" >> /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
	sed -i -e "s~key.converter.schema.registry.url=http://localhost:8081~key.converter.schema.registry.url=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
	sed -i -e "s~value.converter.schema.registry.url=http://localhost:8081~value.converter.schema.registry.url=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties

	sed -i -e "s~#id=kafka-rest-test-server~id=kafka-rest-server~g" /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
	sed -i -e "s~#schema.registry.url=http://localhost:8081~schema.registry.url=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
	sed -i -e "s~#zookeeper.connect=localhost:2181~zookeeper.connect=$SYSTEMIP1:3100,$SYSTEMIP2:3100,$SYSTEMIP3:3100~g" /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
	sed -i -e "s~bootstrap.servers=PLAINTEXT://localhost:9092~bootstrap.servers=PLAINTEXT://$SYSTEMIP1:3400,PLAINTEXT://$SYSTEMIP2:3400,PLAINTEXT://$SYSTEMIP3:3400,PLAINTEXT://$SYSTEMIP4:3400~g" /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
	echo "listeners=http://$SYSTEMIP5:3700" >> /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
	echo "consumer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor" >> /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties
	echo "producer.interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor" >> /work/kafka/confluent-6.1.1/etc/kafka-rest/kafka-rest.properties

	sed -i -e "s~bootstrap.servers=localhost:9092~bootstrap.servers=$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/confluent-6.1.1/etc/ksqldb/ksql-server.properties
	sed -i -e "s~listeners=http://0.0.0.0:8088~listeners=http://$SYSTEMIP5:3800~g" /work/kafka/confluent-6.1.1/etc/ksqldb/ksql-server.properties
	sed -i -e "s~# ksql.schema.registry.url=http://localhost:8081~ksql.schema.registry.url=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/ksqldb/ksql-server.properties
	sed -i -e "s~bootstrap.servers=localhost:9092~bootstrap.servers=$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/confluent-6.1.1/etc/ksqldb/connect.properties
	sed -i -e "s~key.converter.schema.registry.url=http://localhost:8081~key.converter.schema.registry.url=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/ksqldb/connect.properties
	sed -i -e "s~value.converter.schema.registry.url=http://localhost:8081~key.converter.schema.registry.url=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/ksqldb/connect.properties

	sed -i -e "s~bootstrap.servers=localhost:9092~bootstrap.servers=$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	sed -i -e "s~zookeeper.connect=localhost:2181~zookeeper.connect=$SYSTEMIP1:3100,$SYSTEMIP2:3100,$SYSTEMIP3:3100~g" /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	sed -i -e "s~confluent.controlcenter.data.dir=/tmp/confluent/control-center~confluent.controlcenter.data.dir=/work/kafka/ccc~g" /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	sed -i -e "s~confluent.controlcenter.connect.cluster=http://localhost:8083~confluent.controlcenter.connect.cluster=http://$SYSTEMIP5:3600~g" /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	sed -i -e "s~confluent.controlcenter.schema.registry.url=http://localhost:8081~confluent.controlcenter.schema.registry.url=http://$SYSTEMIP5:3500~g" /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	echo "confluent.controlcenter.rest.listeners=http://$SYSTEMIP5:4000" >> /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	sed -i -e "s~confluent.controlcenter.ksql.ksqlDB.url=http://localhost:8088~confluent.controlcenter.ksql.ksqlDB.url=http://$SYSTEMIP5:3800~g" /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	sed -i -e "s~confluent.controlcenter.streams.cprest.url=http://localhost:8090~confluent.controlcenter.streams.cprest.url=http://$SYSTEMIP5:3900~g" /work/kafka/confluent-6.1.1/etc/confluent-control-center/control-center-minimal.properties
	
	sudo mkdir -p /work/kafka/ccc
	rm -rf /work/kafka/ccc/*
	
	sudo mkdir -p /work/kafka/chub
	sudo mkdir -p /work/kafka/confluent-6.1.1/connectors
	sudo rm -rf /work/kafka/chub/*
	sudo chmod -R 777 /work
	cp confluent-hub-client-latest.tar.gz /work/kafka/chub
	pushd /work/kafka/chub
	tar xf confluent-hub-client-latest.tar.gz 
	rm -f confluent-hub-client-latest.tar.gz 
	popd
	sudo chmod -R 777 /work
	
	/work/kafka/chub/bin/confluent-hub install confluentinc/kafka-connect-jdbc:10.0.0 --component-dir /work/kafka/confluent-6.1.1/share/java --worker-configs /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties	
	
	/work/kafka/chub/bin/confluent-hub install debezium/debezium-connector-mysql:1.2.2 --component-dir /work/kafka/confluent-6.1.1/share/java --worker-configs /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties 
	
	/work/kafka/chub/bin/confluent-hub install confluentinc/kafka-connect-hdfs3:latest --component-dir /work/kafka/confluent-6.1.1/share/java --worker-configs /work/kafka/confluent-6.1.1/etc/schema-registry/connect-avro-distributed.properties
	
	sudo systemctl enable kafka-schema-registry && sudo systemctl start kafka-schema-registry
	sudo systemctl enable kafka-connect && sudo systemctl start kafka-connect
	sudo systemctl enable kafka-rest && sudo systemctl start kafka-rest
	sudo systemctl enable kafka-ksql-server && sudo systemctl start kafka-ksql-server
	sudo systemctl enable kafka-control-center && sudo systemctl start kafka-control-center	 
	
	sudo mkdir -p /etc/docker/compose/zoonavigator
	sudo rm -rf /etc/docker/compose/zoonavigator/*
	echo "version: '2.1'

services:
  web:
    image: elkozmon/zoonavigator-web:latest
    container_name: zoonavigator-web
    ports:
     - \"4200:4200\"
    environment:
      WEB_HTTP_PORT: 4200
      API_HOST: \"api\"
      API_PORT: 4100
    depends_on:
     - api
  api:
    image: elkozmon/zoonavigator-api:latest
    container_name: zoonavigator-api
    environment:
      API_HTTP_PORT: 4100" | sudo tee /etc/docker/compose/zoonavigator/docker-compose.yml > /dev/null	
      	docker pull elkozmon/zoonavigator-api:latest
      	docker pull elkozmon/zoonavigator-web:latest
      	sudo systemctl stop docker-compose@zoonavigator
	sudo systemctl start docker-compose@zoonavigator
	
	sudo mkdir -p /etc/docker/compose/kafka-manager
	sudo rm -rf /etc/docker/compose/kafka-manager/*	
	echo "# /etc/docker/compose/kafka-manager/docker-compose.yml
version: '2.1'
services:
  kafka_manager:
    image: hlebalbau/kafka-manager:latest
    ports:
      - \"4210:9000\"
    environment:
      ZK_HOSTS: \"$SYSTEMIP1:3100,$SYSTEMIP2:3100,$SYSTEMIP3:3100\"
      APPLICATION_SECRET: \"random-secret\"
    command: -Dpidfile.path=/dev/null" | sudo tee /etc/docker/compose/kafka-manager/docker-compose.yml > /dev/null	
	docker pull hlebalbau/kafka-manager:latest
      	sudo systemctl stop docker-compose@kafka-manager
	sudo systemctl start docker-compose@kafka-manager
	
	cd ~
	sudo rm -rf kafka-monitor
	git clone https://github.com/linkedin/kafka-monitor.git
	cd kafka-monitor
	sudo yum install -y java-1.8.0-openjdk-devel	
	cd ..
	sudo chmod 777 setupjdk.sh
	sudo mkdir -p /opt/java/oracle
	sudo ./setupjdk.sh
	sudo rm -rf /work/kafka/monitor
	sudo mv kafka-monitor /work/kafka/monitor
	sed -i -e "s~localhost:9092,localhost:9093~$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/monitor/config/xinfra-monitor.properties	
	sed -i -e "s~localhost:9092~$SYSTEMIP1:3400,$SYSTEMIP2:3400,$SYSTEMIP3:3400,$SYSTEMIP4:3400~g" /work/kafka/monitor/config/xinfra-monitor.properties
	sed -i -e "s~localhost:2181~$SYSTEMIP1:3100,$SYSTEMIP2:3100,$SYSTEMIP3:3100~g" /work/kafka/monitor/config/xinfra-monitor.properties		
	sudo chmod -R 777 /work	
	sudo systemctl enable kafka-monitor && sudo systemctl start kafka-monitor
	
	sudo mkdir -p /work/kafka/prometheus
	sudo rm -rf /work/kafka/prometheus/*
	cd ~	
	sudo cp prometheus-2.27.1.linux-amd64.tar.gz /work/kafka/prometheus
	sudo chmod -R 777 /work	
	cd /work/kafka/prometheus
	tar xf prometheus-2.27.1.linux-amd64.tar.gz
	mv prometheus-2.27.1.linux-amd64 core
	rm -f prometheus-2.27.1.linux-amd64.tar.gz
	cd ~
	rm -f /work/kafka/prometheus/core/prometheus.yml
	echo "global:
 scrape_interval: 10s
 evaluation_interval: 10s
scrape_configs:
 - job_name: 'kafka'
   static_configs:
    - targets:
      - $SYSTEMIP1:4220
      - $SYSTEMIP2:4220
      - $SYSTEMIP3:4220
      - $SYSTEMIP4:4220 
 - job_name: 'zookeeper'
   static_configs:
    - targets:
      - $SYSTEMIP1:4215
      - $SYSTEMIP2:4215
      - $SYSTEMIP3:4215" | sudo tee /work/kafka/prometheus/core/prometheus.yml > /dev/null	
      	sudo chmod -R 777 /work
      	sudo systemctl enable kafka-prometheus && sudo systemctl start kafka-prometheus
      	
      	cd ~
      	sudo rm -rf /work/kafka/prometheus/grafana
      	sudo cp grafana-7.5.7.linux-amd64.tar.gz /work/kafka/prometheus
	sudo chmod -R 777 /work	
	cd /work/kafka/prometheus
	tar xf grafana-7.5.7.linux-amd64.tar.gz 
	mv grafana-7.5.7 grafana
	rm -f grafana-7.5.7.linux-amd64.tar.gz
	cd ~
	sed -i '38s/.*/http_port = 4240/' /work/kafka/prometheus/grafana/conf/defaults.ini    
	sed -i '371s/.*/enabled = true/' /work/kafka/prometheus/grafana/conf/defaults.ini
	sed -i '377s/.*/org_role = Admin/' /work/kafka/prometheus/grafana/conf/defaults.ini
	sudo systemctl enable kafka-grafana && sudo systemctl start kafka-grafana		 	
fi

#https://mirrors.estointernet.in/apache/kafka/2.8.0/kafka_2.13-2.8.0.tgz
#https://packages.confluent.io/archive/6.1/confluent-6.1.1.zip
#http://client.hub.confluent.io/confluent-hub-client-latest.tar.gz
#/media/prathamos/Elements/Work/Kafka/Software/setupkfkglobal.sh

#https://apachemirror.wuchna.com/avro/stable/java/avro-tools-1.10.2.jar
#https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.15.0/jmx_prometheus_javaagent-0.15.0.jar
#https://github.com/prometheus/jmx_exporter/raw/master/example_configs/kafka-0-8-2.yml
#https://github.com/prometheus/jmx_exporter/raw/master/example_configs/zookeeper.yaml
#https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz
#https://dl.grafana.com/oss/release/grafana-7.5.7.linux-amd64.tar.gz
#https://github.com/confluentinc/cp-helm-charts/raw/master/grafana-dashboard/confluent-open-source-grafana-dashboard.json

#/media/prathamos/Elements/Work/Kafka/Software/setupjdk.sh
#/media/prathamos/Elements/Work/Kafka/Software/jdk-8u291-linux-x64.tar.gz
#/media/prathamos/Elements/Work/Kafka/Software/setupjdkglobal.sh

#/media/prathamos/Elements/Work/Kafka/Software/kafka-monitor
#/media/prathamos/Elements/Work/Kafka/Software/kfkglobalstart.sh
#/media/prathamos/Elements/Work/Kafka/Software/kfkglobalstatus.sh
#/media/prathamos/Elements/Work/Kafka/Software/kfkglobalstop.sh
#/media/prathamos/Elements/Work/Kafka/Software/jolokia-client-java-1.6.2.jar
#/media/prathamos/Elements/Work/Kafka/Software/jolokia-jvm-1.6.2-agent.jar

