# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                              OS BUILDER
#
# ======================================================================
# TODO :
# * Install kernel header options
# * Do not clear reports dir
# ======================================================================

# Include main library
. $(dirname $(realpath ${0}))/libs/zydux-lib.inc

# **********************************************************************
#                             FUNCTIONS
# **********************************************************************

# Init for all step
common_init()
{
	# Create toolchain directory
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}
	# Add to PATH if need
	zydux_add_dir_to_front_path ${ZYDUX_TOOLCHAIN_DIR}/bin
}

# Export all cross toolchain variables
common_export()
{
	zydux_export CC=${ZYDUX_TARGET}-gcc
	zydux_export CXX=${ZYDUX_TARGET}-g++
	zydux_export AR=${ZYDUX_TARGET}-ar
	zydux_export AS=${ZYDUX_TARGET}-as
	zydux_export LD=${ZYDUX_TARGET}-ld
	zydux_export RANLIB=${ZYDUX_TARGET}-ranlib
	zydux_export READELF=${ZYDUX_TARGET}-readelf
	zydux_export STRIP=${ZYDUX_TARGET}-strip
}

# Make a report at end of step
common_report()
{
	[ ${ZYDUX_CHANGE_REPORT_ENABLED} -eq 0 ] && return
	zydux_ensure_dir_exist ${ZYDUX_REPORTS_DIR}
	zydux_report_change "${ZYDUX_TARGET_DIR}" "${ZYDUX_SNAPSHOT_FILENAME}" "${ZYDUX_REPORTS_DIR}/${ZYDUX_SCRIPT_NOEXT}-${ZYDUX_CMDLINE_CMD}.txt"	
	zydux_report_snapshot "${ZYDUX_TARGET_DIR}" "${ZYDUX_SNAPSHOT_FILENAME}"
	cp ${ZYDUX_SNAPSHOT_FILENAME} ${ZYDUX_REPORTS_DIR}/${ZYDUX_SCRIPT_NOEXT}-${ZYDUX_CMDLINE_CMD}.snapshot
}

# **********************************************************************
#                               COMMANDS
# **********************************************************************

# ----------------------------------------------------------------------
# Command	info
# Brief		Show build info
# ----------------------------------------------------------------------
function cmd_info()
{
	# Section
	zydux_section "BUILD INFO"
	# Info
	zydux_log MSG "$(printf "%-20s : %s\n" "host" "${ZYDUX_HOST}")"
	zydux_log MSG "$(printf "%-20s : %s\n" "target" "${ZYDUX_TARGET}")"
	zydux_log MSG "$(printf "%-20s : %s\n" "arch" "${ZYDUX_ARCH}")"
	zydux_log MSG "$(printf "%-20s : %s\n" "cores/jobs" "${ZYDUX_CORES}/${ZYDUX_JOBS}")"
	zydux_log MSG "$(printf "%-20s : %s\n" "kernel" "$(zydux_source_version_from_url ${ZYDUX_KERNEL_URL})")"
	zydux_log MSG "$(printf "%-20s : %s\n" "busybox" "$(zydux_source_version_from_url ${ZYDUX_BUSYBOX_URL})")"
}

# ----------------------------------------------------------------------
# Command	clean
# Brief		Remove builded toolchain
# ----------------------------------------------------------------------
function cmd_clean()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "CLEAN ENVIRONMENT"
	# Clean
	zydux_delete_dir ${ZYDUX_TARGET_DIR}
	rm -r -f ${ZYDUX_BUILDS_DIR}/${ZYDUX_SCRIPT_NOEXT}*
	rm -r -f ${ZYDUX_REPORTS_DIR}/${ZYDUX_SCRIPT_NOEXT}*
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	download
# Brief		Build binutils
# ----------------------------------------------------------------------
function cmd_download()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "DOWNLOAD PACKAGES"	
	# Download kernel
	zydux_download_source ${ZYDUX_KERNEL_URL}
	# Download Busybox
	zydux_download_source ${ZYDUX_BUSYBOX_URL}	
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	extract
# Brief		Extract all packages
# ----------------------------------------------------------------------
function cmd_extract()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "EXTRACT PACKAGES"		
	# Extract kernel
	zydux_extract_source ${ZYDUX_KERNEL_URL}				
	# Extract Busybox
	zydux_extract_source ${ZYDUX_BUSYBOX_URL}
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	mkrootfs
# Brief		Create target root
# ----------------------------------------------------------------------
function cmd_mkrootfs()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "CREATE ROOT FILESYSTEM"	
	# Init
	common_init	
	# Create filesystem hierarchy (http://www.pathname.com/fhs/)
	zydux_log MSG "Create filesystem hierarchy..."
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/bin
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/boot
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/dev
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc/network
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc/network/if-pre-up.d
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc/network/if-pre-down.d
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc/network/if-post-up.d
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc/network/if-post-down.d
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc/network/if-up.d
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/etc/network/if-down.d
		
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/home	
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/lib
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/lib/firmware
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/lib/modules	
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/mnt
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/opt
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/proc	
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/root
	zydux_chmod 0750 ${ZYDUX_TARGET_DIR}/root	
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/sbin
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/srv
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/sys	
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/tmp
	zydux_chmod 1777 ${ZYDUX_TARGET_DIR}/tmp
		
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/bin
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/include
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/lib
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/sbin
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/share
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/src
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/local
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/local/bin
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/local/include
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/local/lib
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/local/sbin
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/local/share
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/usr/local/src	
	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/cache
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/lib
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/local
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/lock
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/log	
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/opt
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/run
	zydux_ensure_dir_exist ${ZYDUX_TARGET_DIR}/var/spool
	
	# Linking mtab to 
	zydux_log MSG "Linking mtab to /proc/mounts..."
	zydux_link_file ../proc/mounts ${ZYDUX_TARGET_DIR}/etc/mtab
	
	# Create fstab
	zydux_log MSG "Create fstab..."
	echo "# file-system  mount-point  type   options          dump  fsck
/dev/${ZYDUX_ROOT_PART}     /            ${ZYDUX_ROOT_FS}  defaults         1     1" > ${ZYDUX_TARGET_DIR}/etc/fstab
		
	
	# Create users groups
	zydux_log MSG "Create rusers groups..."
	echo "root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:*" > ${ZYDUX_TARGET_DIR}/etc/group

	# Create root account
	zydux_log MSG "Create root account..."
	echo "root::0:0:root:/root:/bin/ash" > ${ZYDUX_TARGET_DIR}/etc/passwd
	
	# Create user logs
	zydux_log MSG "Create user logs..."
	zydux_touch_file ${ZYDUX_TARGET_DIR}/var/run/utmp 
	zydux_chmod 664 ${ZYDUX_TARGET_DIR}/var/run/utmp 
	zydux_touch_file ${ZYDUX_TARGET_DIR}/var/log/btmp 
	zydux_touch_file ${ZYDUX_TARGET_DIR}/var/log/lastlog
	zydux_chmod 664 ${ZYDUX_TARGET_DIR}/var/log/lastlog
	zydux_touch_file ${ZYDUX_TARGET_DIR}/var/log/wtmp
	
	echo "# /etc/inittab

::sysinit:/etc/rc.d/startup

tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6

# Put a getty on the serial line (for a terminal)
# uncomment this line if your using a serial console
#::respawn:/sbin/getty -L ttyS0 115200 vt100

::shutdown:/etc/rc.d/shutdown
::ctrlaltdel:/sbin/reboot
" > ${ZYDUX_TARGET_DIR}/etc/inittab

	# Resources
	cp -R ${ZYDUX_RESOURCES_DIR}/etc ${ZYDUX_TARGET_DIR}
	cp -R ${ZYDUX_RESOURCES_DIR}/usr ${ZYDUX_TARGET_DIR}
	
	
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	busybox
# Brief		Build busybox
# ----------------------------------------------------------------------
function cmd_busybox()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "BUILD BUSYBOX"
	# Init
	common_init
	# Usefull variables	
	busybox_source_dir=$(zydux_source_dir_from_url ${ZYDUX_BUSYBOX_URL})	
	# Enter dir
	zydux_enter_dir ${busybox_source_dir} 
	# Export
	common_export
	# Mr Proper
	zydux_exec make distclean	
	# Default config
	zydux_export ARCH=${ZYDUX_ARCH}
	zydux_exec make defconfig
	# Adjust config
	sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
	sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config
	sed -i 's/\(CONFIG_FEATURE_WTMP\)=y/# \1 is not set/' .config
	sed -i 's/\(CONFIG_FEATURE_UTMP\)=y/# \1 is not set/' .config
	sed -i 's/\(CONFIG_UDPSVD\)=y/# \1 is not set/' .config
	sed -i 's/\(CONFIG_TCPSVD\)=y/# \1 is not set/' .config
	# Make
	zydux_export ARCH=${ZYDUX_ARCH}
	zydux_export CROSS_COMPILE=${ZYDUX_TARGET}-
	zydux_exec make -j${ZYDUX_JOBS} 
	# Install
	zydux_export ARCH=${ZYDUX_ARCH}
	zydux_export CROSS_COMPILE=${ZYDUX_TARGET}-
	zydux_exec make CONFIG_PREFIX=${ZYDUX_TARGET_DIR} install	
	# Copy depmod	
	zydux_copy_file examples/depmod.pl ${ZYDUX_TARGET_DIR}/bin
	zydux_chmod 755 ${ZYDUX_TARGET_DIR}/bin/depmod.pl
	# Leave dir	
	zydux_leave_dir
	# Info
	zydux_export LD_LIBRARY_PATH=${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET}/lib:${LD_LIBRARY_PATH}
	zydux_exec ldd ${ZYDUX_TARGET_DIR}/bin/busybox
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	kernel
# Brief		Build kernel
# ----------------------------------------------------------------------
function cmd_kernel()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "BUILD KERNEL"
	# Init
	common_init
	# Usefull variables
	kernel_source_dir=$(zydux_source_dir_from_url ${ZYDUX_KERNEL_URL})
	# Enter dir	
	zydux_enter_dir ${kernel_source_dir}
	# Export
	common_export
	# Mr Proper
	zydux_exec	make mrproper
	# Default config
	zydux_exec make ${ZYDUX_KERNEL_DEFAULT_CONFIG}		
	# Make
	zydux_exec make ARCH=${ZYDUX_ARCH} CROSS_COMPILE=${ZYDUX_TARGET}- -j${ZYDUX_JOBS}	
	# Module
	zydux_exec make ARCH=${ZYDUX_ARCH} CROSS_COMPILE=${ZYDUX_TARGET}- INSTALL_MOD_PATH=${ZYDUX_TARGET_DIR} modules_install	
	# Get kernel, config , sysmap	
	zydux_copy_file arch/${ZYDUX_ARCH}/boot/bzImage ${ZYDUX_TARGET_DIR}/boot
	zydux_copy_file System.map ${ZYDUX_TARGET_DIR}/boot
	zydux_copy_file .config ${ZYDUX_TARGET_DIR}/boot
	# Leave dir
	zydux_leave_dir
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	finalize
# Brief		Install libc, set rights
# ----------------------------------------------------------------------
function cmd_finalize()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "FINALIZATION"	
	# Copy .so
	zydux_log MSG "Installing libc from toolchain"
	cp -vP ${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET}/lib/*.so* ${ZYDUX_TARGET_DIR}/lib/
	# Changing owner
	zydux_log MSG "Changing ownership of target..."
	chown -Rv root:root ${ZYDUX_TARGET_DIR}
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# **********************************************************************
#                              ENTRY POINT
# **********************************************************************

# Execute command
zydux_cmdline_exec "all" ${@}


