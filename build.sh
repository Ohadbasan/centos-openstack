#!/bin/bash
wget -N http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum localinstall epel-release-6-8.noarch.rpm
yum install -y livecd-tools
livecd-creator -d -v  --config=kickstart/openstack-live-gnome.ks --cache=/home --fslabel=openstack-live > iso.log 2>&1
