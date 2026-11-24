#!/bin/bash
set -e
set -x
# The disk is attached after the VM has booted, so wait for it to appear.
for i in $(seq 1 60); do
  [ -e ${device} ] && break
  sleep 5
done
mkfs -t xfs ${device}
mkdir -p ${mount_point}
echo "UUID=$(blkid -o value -s UUID ${device}) ${mount_point} xfs defaults,nofail 0 2" | tee -a /etc/fstab
mount -a
