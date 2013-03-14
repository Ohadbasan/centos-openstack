########################################################################
#
#  LiveCD with gnome desktop
#
#  Urs Beyerle, ETHZ
#
########################################################################

part / --size 16000 --fstype ext4

########################################################################
# Include kickstart files
########################################################################

%include openstack-live-base.ks
rootpw  --iscrypted $1$Xf6TgRMn$CaeeBnC/kbFxOxBbu7jtQ/

########################################################################
# Packages
########################################################################

%packages
# packages removed from @base
-bind-utils
-ed
-kexec-tools
-system-config-kdump
-libaio
-libhugetlbfs
-microcode_ctl
-psacct
-quota
-autofs
-smartmontools

@basic-desktop
# package removed from @basic-desktop
-gok

@desktop-platform
# packages removed from @desktop-platform
-redhat-lsb


@fonts

@general-desktop
# package removed from @general-desktop
-gnome-backgrounds
-gnome-user-share
-nautilus-sendto
-orca
-rhythmbox
-vino
-compiz
-compiz-gnome
-evince-dvi
-gnote
-sound-juicer

# @input-methods

@internet-applications
# package added to @internet-applications
# xchat
# packages removed from @internet-applications
-ekiga

@internet-browser

### SL LiveCD specific changes

## packages to remove to save diskspace
-evolution
-evolution-help
-evolution-mapi
-scenery-backgrounds
-redhat-lsb-graphics
-qt3
-xinetd
-openswan
-pinentry-gtk
-seahorse
-hunspell-*
-words
-nano
-pinfo
-vim-common
-vim-enhanced
-samba-common
-samba-client
-mousetweaks
patch
bridge-utils
net-tools
firefox
m2crypto
seabios
qemu-kvm-tools
vim
net-tools
bridge-utils
shadow-utils
lvm2
epel-release
openstack-utils
puppet
#yum-plugins-priorities

## remove some fonts and input methods
# remove Chinese font (Ming face) (8.9 MB)
# we still have wqy-zenhei-fonts 
-cjkuni-fonts-common
-cjkuni-uming-fonts
# remove Korean input method (2.1 MB)
-ibus-hangul
-libhangul

## packages to add
lftp
thunderbird
#@openafs-client
cups
cups-pk-helper
system-config-printer
system-config-printer-udev
xorg-x11-fonts-100dpi
xorg-x11-fonts-ISO8859-1-100dpi
xorg-x11-fonts-Type1
nautilus-sendto
spice-client
spice-xpi
phonon-backend-gstreamer

#openstack packages

#openstack-packstack
openstack-packstack
openstack-nova-objectstore
openstack-nova
openstack-dashboard
openstack-glance
openstack-nova-volume
openstack-cinder
openstack-nova-api
openstack-nova-network
openstack-nova-novncproxy
python-django-openstack-auth
openstack-nova-scheduler
openstack-keystone
openstack-nova-common
openstack-nova-compute
openstack-nova-console
openstack-utils
openstack-nova-cert

%end


########################################################################
# Post installation
########################################################################

%post --nochroot
cp -r openstackLiveFiles $INSTALL_ROOT/root/
%end


%post

mkdir -p /home/liveuser/openstackLiveFiles

cp -r /root/openstackLiveFiles /home/liveuser


#find /home/liveuser/openstackLiveFiles/patches -name '*.patch' | sort | while read patch; do
#    patch -d /usr/share/ovirt-engine/scripts < "$patch"
#done

#settings up vdsm to use a dummy nic
#cp /home/liveuser/openstackLiveFiles/50-vdsm-conf-fake-nic.conf /etc/ovirt-host-deploy.conf.d/
#echo '10.0.0.1 livecd.localdomain localdomain' >> /etc/hosts

#copying plugin
#cp /home/liveuser/openstackLiveFiles/ovirt_live_101.py /usr/share/ovirt-engine/scripts/plugins/

#copying network files
#cp /home/liveuser/openstackLiveFiles/etc/sysconfig/network-scripts/* /etc/sysconfig/network-scripts/

# remove folders/files that use a lot of diskspace
# and are not really needed for LiveCD
rm -rf /usr/share/doc/openafs-*
rm -rf /usr/share/doc/testdisk-*

#workaround for bz 878119
#echo 'blacklist iTCO_wdt' >> /etc/modprobe.d/blacklist.conf
#echo 'blacklist iTCO_vendor_support' >> /etc/modprobe.d/blacklist.conf
sed -i 's/\#WDMDOPTS/WDMDOPTS/g' /etc/sysconfig/wdmd

# Manipulate fqdn validation, so that it is possible to setup with answer file
#sed -i 's/raise Exception(output_messages.ERR_EXP_VALIDATE_PARAM % param.getKey("CONF_NAME"))/logging.debug("Failed to validate %s with value %s",param,paramValue)/g' /usr/share/ovirt-engine/scripts/engine-setup.py

#setting up wallpaper
gconftool-2 -t str -s /desktop/gnome/background/picture_filename "/home/liveuser/openstackLiveFiles/images/openstackwallpaper1.png"

#configuring autostart
mkdir -p /home/liveuser/.config/autostart

#copying autostart and desktop shortcuts
cp /home/liveuser/openstackLiveFiles/usr/share/applications/* /usr/share/applications/

#link setup in autostart
cp /usr/share/applications/engine-setup.desktop /home/liveuser/.config/autostart/

#yum localinstall -y /home/liveuser/openstackLiveFiles/rpms/*.rpm

#placing repo files
rm -f /etc/yum.repos.d/*
cp /home/liveuser/openstackLiveFiles/etc/yum.repos.d/* /etc/yum.repos.d/

#generating rsa keys
ssh-keygen -N "" -f /root/.ssh/id_rsa
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

%end
