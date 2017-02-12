# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                             CONFIGURATION FILE
#
# ======================================================================

# TARGET

ZYDUX_ARCH="x86"
ZYDUX_TARGET="i486-zydux-linux-musl"

# KERNEL

ZYDUX_KERNEL_DEFAULT_CONFIG="i386_defconfig"

# ROOT

ZYDUX_ROOT_SIZE=128M
ZYDUX_ROOT_FS=ext4
ZYDUX_ROOT_PART=/dev/sda1

# GCC

ZYDUX_GCC_NO_BOOSTRAP=1

# PACKAGES

ZYDUX_KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.7.tar.xz"
ZYDUX_BINUTILS_URL="http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.bz2"
ZYDUX_GCC_URL="http://ftp.gnu.org/gnu/gcc/gcc-6.3.0/gcc-6.3.0.tar.bz2"
ZYDUX_MPFR_URL="http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.5.tar.xz"
ZYDUX_GMP_URL="http://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz"
ZYDUX_MPC_URL="http://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"
ZYDUX_MUSL_URL="http://www.musl-libc.org/releases/musl-1.1.16.tar.gz"
ZYDUX_BUSYBOX_URL="https://www.busybox.net/downloads/busybox-1.26.2.tar.bz2"

# JOBS

ZYDUX_JOBS_PER_CORE=1.5

# LOGS

ZYDUX_LOG_ENABLED=1
ZYDUX_LOG_CLEAR_AT_STARTUP=0
ZYDUX_LOG_DATE_FORMAT="%Y-%m-%d %H:%M:%S"

# REPORT

ZYDUX_CHANGE_REPORT_ENABLED=1

# OPTIONS

ZYDUX_COLOR_ENABLED=1
ZYDUX_VERBOSE_ENABLED=0
ZYDUX_DEBUG_ENABLED=0

# QEMU

ZYDUX_QEMU_SYSTEM="qemu-system-i386"
ZYDUX_QEMU_RAM="64M"

# SYSLINUX
ZYDUX_SYSLINUX_MBR=/usr/lib/syslinux/mbr/mbr.bin

