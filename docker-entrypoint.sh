#!/bin/bash

exec java -jar exhibitor.jar --defaultconfig /zookeeper/exhibitor.properties $@
