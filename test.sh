#rm testdriver.qcow2
#qemu-img create -f qcow2 testdriver.qcow2 1G

#rm /tmp/guest.in /tmp/guest.out
#mkfifo /tmp/guest.in /tmp/guest.out

dd if=/dev/zero of=disk.img bs=1M count=64

# Put a FAT filesystem on it (use -F for FAT32, otherwise it's automatic)
mformat -i disk.img ::
mcopy -i disk.img /home/jlewis/shim/shimx64.efi ::
mcopy -i disk.img /home/jlewis/shim_debug_tools/grubx64.efi ::
#mcopy -i disk.img ../set_var/setdbg.efi ::
mcopy -i disk.img /home/jlewis/my_uefi_app/gnu-efi/x86_64/apps/setdbg.efi ::
mcopy -i disk.img /home/jlewis/my_uefi_app/gnu-efi/x86_64/apps/unsetdbg.efi ::

# List files
mdir -i disk.img ::

#$PREFIX/bin/qemu-system-x86_64 -L . -bios OVMF.fd -net none -drive file=disk.img -vga cirrus -enable-kvm #-monitor stdio -serial tcp::6666,server -s
#$PREFIX/bin/qemu-system-x86_64 -pflash DEBUGX64_OVMF.fd -hda fat:rw:hda-contents -drive if=pflash,format=raw,unit=1,file=DEBUGX64_OVMF_VARS.fd -net none -vga cirrus -enable-kvm #-monitor stdio -serial tcp::6666,server -s

#$PREFIX/bin/qemu-system-x86_64 -pflash OVMF.fd -drive unit=1,file=disk.img -net none -enable-kvm -serial pipe:/tmp/guest -s #-enable-kvm -singlestep #assumed port 1234 #-serial tcp::6666,server -s
$PREFIX/bin/qemu-system-x86_64 -pflash OVMF.fd -drive unit=1,file=disk.img -net none -serial pipe:/tmp/guest -s #-enable-kvm -singlestep #assumed port 1234 #-serial tcp::6666,server -s

#-drive if=pflash,format=raw,unit=0,readonly,file=OVMF_CODE-pure-efi.fd \
#-drive if=pflash,format=raw,unit=1,file=OVMF_VARS-pure-efi.fd \


# Put a FAT filesystem on it (use -F for FAT32, otherwise it's automatic)
#mformat -i testdriver.qcow2 ::
#mcopy -i testdriver.qcow2 /home/jlewis/edk2/Build/MdeModule/DEBUG_GCC5/X64/MyDriver.efi ::
#mcopy -i testdriver.qcow2 /home/jlewis/edk2/Build/MdeModule/DEBUG_GCC5/X64/HelloWorld.efi ::
#mcopy -i testdriver.qcow2 ../shimx64.efi ::
#mcopy -i testdriver.qcow2 ./image/efi/boot/bootx64.efi ::

#$PREFIX/bin/qemu-system-x86_64 -L . -bios OVMF.fd \
    #-vga cirrus -monitor stdio -serial tcp::6666,server -s -drive file=testdriver.qcow2 -enable-kvm
 #$PREFIX/bin/qemu-system-x86_64 -L . -bios OVMF.fd -net none -drive file=testdriver.qcow2 -vga cirrus -enable-kvm # -monitor stdio -serial tcp::6666,server -s

# "C:\Program Files\qemu\qemu-system-x86_x64.exe" -L . -bios OVMF.fd -net none -drive file=testdriver.qcow2
