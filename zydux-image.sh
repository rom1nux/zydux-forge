# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                         IMAGE BUILDER / EMULATION
#
# ======================================================================


# Include main library
. $(dirname $(realpath ${0}))/libs/zydux-lib.inc

# **********************************************************************
#                               COMMANDS
# **********************************************************************

# ----------------------------------------------------------------------
# Command	build
# Brief		Build image
# ----------------------------------------------------------------------
function cmd_build()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "MAKE HDD IMAGE"
	# Create raw file
	zydux_delete_file ${ZYDUX_IMG_FILENAME}
	zydux_log MSG "Create empty file (${ZYDUX_ROOT_SIZE})..." 
	zydux_exec dd if=/dev/zero of=${ZYDUX_IMG_FILENAME} bs=${ZYDUX_ROOT_SIZE} count=1
	# Create Partition
	zydux_log MSG "Create image partition..." 
	echo "n
p
1
2048

p
a
p
w
q" | fdisk ${ZYDUX_IMG_FILENAME}
	#[ $? -ne 0 ] && zydux_log "Could not create partition !"
	# Installing MBR
	zydux_log MSG "Installing MBR on image partition..." 
	zydux_exec dd if=${ZYDUX_SYSLINUX_MBR} of=${ZYDUX_IMG_FILENAME} conv=notrunc
	# Mount loop
	zydux_log MSG "Mounting image partition to loop..." 
	zydux_exec sudo losetup -o $((2048 * 512)) /dev/loop0 ${ZYDUX_IMG_FILENAME}
	# Format
	zydux_log MSG "Format image partition..." 
	zydux_exec sudo mkfs.${ZYDUX_ROOT_FS} /dev/loop0
	# Tune
	zydux_log MSG "Tunning image partition..." 
	zydux_exec sudo tune2fs -L "zydux" /dev/loop0
	# Mounting
	zydux_log MSG "Mounting image partition to loop..."
	zydux_ensure_dir_exist ${ZYDUX_MNT_DIR}
	zydux_exec sudo mount /dev/loop0 ${ZYDUX_MNT_DIR}
	
	# Installing bootloader
	zydux_log MSG "Installing bootloader..."
	zydux_exec sudo mkdir -p ${ZYDUX_MNT_DIR}/boot/extlinux
	zydux_exec sudo extlinux --install ${ZYDUX_MNT_DIR}/boot/extlinux
	
	# Installing bootloader config file
	zydux_log MSG "Installing bootloader config..."	
	echo "prompt 1
default ZYDUX
timeout 5
serial 0 38400
say ZYDUX V${ZYDUX_FORGE_VERSION} - ${ZYDUX_FORGE_COPYRIGHT}
label ZYDUX
	kernel /boot/bzImage
	append root=/dev/sda1 console=tty console=ttyS0,38400 init /sbin/init
" |  sudo tee -a ${ZYDUX_MNT_DIR}/boot/extlinux/extlinux.conf  > /dev/null		
	#initrd=/boot/initrd.img-$vers 
	
	# Copy target
	zydux_log MSG "Copy target..."	
	zydux_exec sudo cp -v -r -p ${ZYDUX_TARGET_DIR}/* ${ZYDUX_MNT_DIR}

	# Unmount
	zydux_log MSG "Unmount image partition..." 
	zydux_exec sudo umount ${ZYDUX_MNT_DIR}
	# Mount from loop
	zydux_log MSG "Unmount image partition from loop..." 
	zydux_exec sudo losetup -d /dev/loop0

	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	mount
# Brief		Mount image
# ----------------------------------------------------------------------
function cmd_mount()
{
	# Section
	zydux_section "MOUNT IMAGE"
	# Mount loop
	zydux_log MSG "Mounting image partition to loop..." 
	zydux_exec sudo losetup -o $((2048 * 512)) /dev/loop0 ${ZYDUX_IMG_FILENAME}
	# Mounting
	zydux_log MSG "Mounting image partition to loop..."
	zydux_ensure_dir_exist ${ZYDUX_MNT_DIR}
	zydux_exec sudo mount /dev/loop0 ${ZYDUX_MNT_DIR}
	# Done
	zydux_log SUCCESS "Done !"
}

# ----------------------------------------------------------------------
# Command	umount
# Brief		Unmount image
# ----------------------------------------------------------------------
function cmd_umount()
{
	# Section
	zydux_section "UNMOUNT IMAGE"
	# Unmount
	zydux_log MSG "Unmount image partition..." 
	zydux_exec sudo umount ${ZYDUX_MNT_DIR}
	# Mount from loop
	zydux_log MSG "Unmount image partition from loop..." 
	zydux_exec sudo losetup -d /dev/loop0
	# Done
	zydux_log SUCCESS "Done !"
}


# ----------------------------------------------------------------------
# Command	qemu
# Brief		Emulate image
# ----------------------------------------------------------------------
function cmd_qemu()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "QEMU IMAGE"
	# Emulation
	zydux_log MSG "Starting emulation..." 
	zydux_exec ${ZYDUX_QEMU_SYSTEM} -m ${ZYDUX_QEMU_RAM} \
									-vga std \
									-boot c \
									-serial stdio \
									-drive format=raw,file=${ZYDUX_IMG_FILENAME}
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# **********************************************************************
#                              ENTRY POINT
# **********************************************************************

# Execute command
zydux_cmdline_exec "no-all" ${@}


