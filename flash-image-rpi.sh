#!/bin/bash

echo "Script required wic image"

sudo bmaptool copy <image file>.rootfs.wic.bz2 --bmap <image file>.rootfs.wic.bmap <device>
