#!/bin/bash

umount system-tmp

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

if [ -f "$1" ];then
    srcFile="$1"
fi

if [ ! -f "$srcFile" ];then
	exit 1
fi

"$origin"/simg2img "$srcFile" system-out.img || cp "$srcFile" system-out.img

mkdir -p system-tmp
e2fsck -y -f system-out.img
resize2fs system-out.img 2000M
e2fsck -E unshare_blocks -y -f system-out.img
mount -o loop,rw system-out.img system-tmp

rm system-tmp/system/bin/phh-su
rm system-tmp/system/etc/init/su.rc

sleep 1

umount system-tmp

e2fsck -f -y system-out.img || true