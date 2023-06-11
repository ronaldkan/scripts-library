#! /bin/bash
pvcreate /dev/sdb
vgcreate docker-vg /dev/sdb
lvcreate -L 99G -n docker-vg docker