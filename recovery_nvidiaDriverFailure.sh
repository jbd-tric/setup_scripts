#!/bin/bash

# Recovery sequence if booting is halted after nvidia graphics driver updates
echo "Removing nvidia drivers..."
apt remove --purge '^nvidia-.*'

echo "Reinstalling nouveau open source graphics drivers..."
apt install xserver-xorg-video-nouveau

echo "Reconfiguring the package database..."
dpkg --configure -a

echo "Updating initial ramdisk filesystem..."
update-initramfs -u

echo "Updating the GRUB boot menu..."
update-grub

echo "Rebooting in 3 seconds..."
sleep 3
reboot now