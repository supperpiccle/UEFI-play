# Create the actual disk image - 200MB
dd if=/dev/zero of=mink.img count=200 bs=1048576
 
# Make the partition table, partition and set it bootable.
parted --script mink.img mklabel msdos mktable gpt mkpart p fat32 0% 50% mkpart p ext2 50% 100% set 2 boot on
 
# Map the partitions from the image file
kpartx -a -s mink.img
 
# sleep a sec, wait for kpartx to create the device nodes
while [ ! -e /dev/mapper/loop0p1 ]; do echo "not found"; sleep 1; done
 
# Make an ext2 filesystem on the first partition.
mkfs.fat -F 32 /dev/mapper/loop0p1
mkfs.ext2 /dev/mapper/loop0p2
 
# Make the mount-point
mkdir -p mounts/efi
mkdir -p mounts/drive
 
losetup -v  --show /dev/loop2 /dev/mapper/loop0p1 # efi
losetup -v  --show /dev/loop3 /dev/mapper/loop0p2 # drive

# Mount the filesystem via loopback
mount /dev/loop2 mounts/efi
mount /dev/loop3 mounts/drive

 
# Copy in the files from the staging directory
#cp ./grubx64.efi build/tmp/p1
 
# Create a device map for grub
#echo "(hd0) /dev/loop2" > mounts/device.map
#echo "(hd0,1) /dev/loop3" >> mounts/device.map
 
## Use grub2-install to actually install Grub. The options are:
##   * No floppy polling.
##   * Use the device map we generated in the previous step.
##   * Include the basic set of modules we need in the Grub image.
##   * Install grub into the filesystem at our loopback mountpoint.
##   * Install the MBR to the loopback device itself.
#/home/jlewis/grub/grub-install --no-floppy \
#              --grub-mkdevicemap=mount/device.map \
#              --root-directory=mounts/mount1 \
#              --efi-directory=mounts/mount2 \
#              --target x86_64-efi \
#              /dev/loop0

/home/jlewis/grub/grub-install --target=x86_64-efi \
               --directory=/home/jlewis/grub/grub-core \
               --efi-directory=./mounts/efi/ \
               --bootloader-id=GRUB \
               --modules="normal part_msdos part_gpt multiboot" \
               --root-directory=./mounts/drive/ \
               --no-floppy \
               /dev/loop0

# Move grub to where shim expects.
cp ./mounts/efi/EFI/GRUB/grubx64.efi ./mounts/efi/grubx64.efi

# Copy shim!
cp  /home/jlewis/shim/shimx64.efi ./mounts/efi/shimx64.efi

 
## Unmount the loopback
umount mounts/efi
umount mounts/drive

losetup -D
 
# Unmap the image
kpartx -d mink.img
 
# hack to make everything owned by the original user, since it will currently be
# owned by root...
LOGNAME=`who am i | awk '{print $1}'`
LOGGROUP=`groups $LOGNAME | awk '{print $3}'`
chown $LOGNAME:$LOGGROUP mink.img


# Copy mink to the windows location.
cp mink.img /mnt/c/Users/cplus/Documents/uefi_play/shim_debug_tools/mink.img