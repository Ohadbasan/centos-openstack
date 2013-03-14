#!/bin/bash
gconftool-2 -t str -s /desktop/gnome/background/picture_filename "/home/liveuser/openstackLiveFiles/images/openstackwallpaper1.png"
cd /home/liveuser/
packstack --gen-answer-file=ans.txt
#get system nic
nic=`cat /proc/net/dev | awk -F: 'FNR==4 {print $1}'`
sed -i "s/eth1/$nic/g" ans.txt
sed -i "s/eth0/$nic/g" ans.txt
#configure password
sed -i 's/CONFIG_KEYSTONE_ADMIN_PW=.*/CONFIG_KEYSTONE_ADMIN_PW=openstack/g' ans.txt
sudo find /usr/lib/python2.6 -type f -print0 | sudo xargs -0 sed -i 's/loop2/loop5/g'

sudo packstack --answer-file=ans.txt << EOF
openstack
EOF

sleep 5
/usr/bin/firefox http://127.0.0.1 &

