# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=IMMENSITY @CuntsSpace
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=raphael
device.name2=raphaelin
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel install
dump_boot;

decomp_image=$home/Image
comp_image=$decomp_image.gz

# Hex-patch the kernel if Magisk is installed ('skip_initramfs' -> 'want_initramfs')
# This negates the need to reflash Magisk afterwards
if [ -f $comp_image ]; then
  comp_rd=$split_img/ramdisk.cpio
  decomp_rd=$home/_ramdisk.cpio
  $bin/magiskboot decompress $comp_rd $decomp_rd || cp $comp_rd $decomp_rd

  if $bin/magiskboot cpio $decomp_rd "exists .backup"; then
    ui_print "  • Preserving Magisk";
    $bin/magiskboot decompress $comp_image $decomp_image;
    $bin/magiskboot hexpatch $decomp_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300;
    $bin/magiskboot compress=gzip $decomp_image $comp_image;
  fi;

  # Concatenate all DTBs to the kernel
  cat $comp_image $home/dtbs/*.dtb > $comp_image-dtb;
  rm -f $decomp_image $comp_image
fi;

write_boot;
## end install

