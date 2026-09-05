#!/bin/bash

sudo chmod 777 setupjdk.sh
sudo mkdir -p /opt/java/oracle
sudo mv jdk-8u291-linux-x64.tar.gz /opt/java
sudo ./setupjdk.sh

