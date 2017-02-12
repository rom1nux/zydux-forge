# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                             TOOLCHAIN BUILDER
#
# ======================================================================
# TODO :
#
# - Actually process die at step "gcc_2", but if "gcc_2" is restarted
#   build continue without problem. It's probably an export conflict
#   from previous step, i found in config.log :
#   After die :
#    ...
#    configure:4078: checking for x86_64-linux-gnu-gcc
#    configure:4105: result: i486-zydux-linux-musl-gcc  <<< WTF ???
#    ...
#    configure:4517: error: cannot run C compiled programs.
#    ...
#   After restart the step wihout any change :
#    ...
#    configure:4078: checking for x86_64-linux-gnu-gcc
#    configure:4094: found /usr/bin/x86_64-linux-gnu-gcc
#    ...
#
# - After "musl" step, the loader "...lib/ld-musl-i386.so.1"is found,
#   it's a link to /lib/libc.so. But after "gcc_2" the link is removed
#   I create a "loader" step to create the link but hop i will understand
#   why the link is removed
#
# - Add C++ support
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
	zydux_ensure_dir_exist ${ZYDUX_TOOLCHAIN_DIR}
	# Add to PATH if need
	zydux_add_dir_to_front_path ${ZYDUX_TOOLCHAIN_DIR}/bin
}

# Make a report at end of step
common_report()
{
	[ ${ZYDUX_CHANGE_REPORT_ENABLED} -eq 0 ] && return
	zydux_ensure_dir_exist ${ZYDUX_REPORTS_DIR}
	zydux_report_change "${ZYDUX_TOOLCHAIN_DIR}" "${ZYDUX_SNAPSHOT_FILENAME}" "${ZYDUX_REPORTS_DIR}/${ZYDUX_SCRIPT_NOEXT}-${ZYDUX_CMDLINE_CMD}.txt"
	zydux_report_snapshot "${ZYDUX_TOOLCHAIN_DIR}" "${ZYDUX_SNAPSHOT_FILENAME}"
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
	zydux_log MSG "$(printf "%-20s : %s\n" "binutils" "$(zydux_source_version_from_url ${ZYDUX_BINUTILS_URL})")"
	zydux_log MSG "$(printf "%-20s : %s\n" "gcc" "$(zydux_source_version_from_url ${ZYDUX_GCC_URL})")"	
	zydux_log MSG "$(printf "%-20s : %s\n" "mpfr" "$(zydux_source_version_from_url ${ZYDUX_MPFR_URL})")"
	zydux_log MSG "$(printf "%-20s : %s\n" "gmp" "$(zydux_source_version_from_url ${ZYDUX_GMP_URL})")"
	zydux_log MSG "$(printf "%-20s : %s\n" "mpc" "$(zydux_source_version_from_url ${ZYDUX_MPC_URL})")"
	zydux_log MSG "$(printf "%-20s : %s\n" "musl" "$(zydux_source_version_from_url ${ZYDUX_MUSL_URL})")"
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
	zydux_delete_dir ${ZYDUX_TOOLCHAIN_DIR}	
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
	# Download binutils
	zydux_download_source ${ZYDUX_BINUTILS_URL}
	# Download gcc
	zydux_download_source ${ZYDUX_GCC_URL}	
	zydux_download_source ${ZYDUX_GMP_URL}
	zydux_download_source ${ZYDUX_MPC_URL}
	zydux_download_source ${ZYDUX_MPFR_URL}		
	# Download Musl
	zydux_download_source ${ZYDUX_MUSL_URL}		
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
	# Extract binutils
	zydux_extract_source ${ZYDUX_BINUTILS_URL}
	# Extract gcc
	zydux_extract_source ${ZYDUX_GCC_URL}	
	zydux_extract_source ${ZYDUX_GMP_URL}	
	zydux_extract_source ${ZYDUX_MPC_URL}	
	zydux_extract_source ${ZYDUX_MPFR_URL}
	# Download Musl
	zydux_extract_source ${ZYDUX_MUSL_URL}			
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	kernel_headers
# Brief		Installer kernel headers
# ----------------------------------------------------------------------
function cmd_kernel_headers()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "INSTALL KERNEL HEADER"
	# Init
	common_init
	# Usefull variables
	kernel_source_dir=$(zydux_source_dir_from_url ${ZYDUX_KERNEL_URL})
	kernel_header_dir=${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET}/usr
	# Enter dir	
	zydux_enter_dir ${kernel_source_dir}
	# Mr Proper
	zydux_exec	make mrproper
	# Check
	zydux_exec	make \
				ARCH=${ZYDUX_ARCH} \
				INSTALL_HDR_PATH=${kernel_header_dir} \
				headers_check			
	# Install
	zydux_exec	make \
				ARCH=${ZYDUX_ARCH} \
				INSTALL_HDR_PATH=${kernel_header_dir} \
				headers_install					
	# Leave dir
	zydux_leave_dir
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	binutils
# Brief		Build binutils
# ----------------------------------------------------------------------
function cmd_binutils()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "BUILD BINUTILS"
	# Init
	common_init
	# Usefull variables	
	binutils_source_dir=$(zydux_source_dir_from_url ${ZYDUX_BINUTILS_URL})
	binutils_build_dir=${ZYDUX_BUILDS_DIR}/${ZYDUX_SCRIPT_NOEXT}-binutils
	# Reset build directory
	zydux_delete_dir ${binutils_build_dir}
	zydux_ensure_dir_exist ${binutils_build_dir}
	# Enter dir
	zydux_enter_dir ${binutils_build_dir} 
	# Configure
	zydux_exec 		${binutils_source_dir}/configure \
					--target=${ZYDUX_TARGET} \
					--prefix=${ZYDUX_TOOLCHAIN_DIR} \
					--with-sysroot=${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET} \
					--with-pkgversion=${ZYDUX_PKGVERSION} \
					--disable-nls \
					--disable-multilib
	# Configure host
	zydux_exec make configure-host
	# Make
	zydux_exec make -j${ZYDUX_JOBS} 
	# Install
	zydux_exec make install	
	# Leave dir
	zydux_leave_dir
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	gcc_1
# Brief		Build gcc step 1
# ----------------------------------------------------------------------
function cmd_gcc_1()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "BUILD GCC STATIC (STEP 1)"
	# Init
	common_init
	# Usefull variables		
	gcc_source_dir=$(zydux_source_dir_from_url ${ZYDUX_GCC_URL})		
	mpfr_source_dir=$(zydux_source_dir_from_url ${ZYDUX_MPFR_URL})
	gmp_source_dir=$(zydux_source_dir_from_url ${ZYDUX_GMP_URL})
	mpc_source_dir=$(zydux_source_dir_from_url ${ZYDUX_MPC_URL})	
	gcc_build_dir=${ZYDUX_BUILDS_DIR}/${ZYDUX_SCRIPT_NOEXT}-gcc_1
	# Linking gcc lib
	zydux_log MSG "Linking external libraries..."
	zydux_enter_dir ${gcc_source_dir}
	zydux_link_file ${mpfr_source_dir} mpfr
	zydux_link_file ${gmp_source_dir} gmp
	zydux_link_file ${mpc_source_dir} mpc
	zydux_leave_dir
	# Sanity
	zydux_delete_dir ${gcc_build_dir}
	zydux_ensure_dir_exist ${gcc_build_dir}	
	# Enter dir	
	zydux_enter_dir ${gcc_build_dir}
	# Extra args
	extargs=""
	if [ ${ZYDUX_GCC_NO_BOOSTRAP} -eq 1 ]; then
		zydux_log NOTICE "GCC bootstrap disabled !"
		extargs="${extargs}--disable-bootstrap "
	fi
	# Configure	
	zydux_exec		${gcc_source_dir}/configure \
					--build=${ZYDUX_HOST} \
					--host=${ZYDUX_HOST} \
					--target=${ZYDUX_TARGET} \
					--prefix=${ZYDUX_TOOLCHAIN_DIR} \
					--with-sysroot=${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET} \
					--with-pkgversion=${ZYDUX_PKGVERSION} \
					--disable-nls  \
					--disable-shared \
					--without-headers \
					--with-newlib \
					--disable-decimal-float \
					--disable-libgomp \
					--disable-libmudflap \
					--disable-libssp \
					--disable-libatomic \
					--disable-libquadmath \
					--disable-threads \
					--disable-multilib \
					--enable-languages=c \
					${extargs}
	# Make
	zydux_exec make -j${ZYDUX_JOBS} all-gcc
	# Make
	zydux_exec make -j${ZYDUX_JOBS} all-target-libgcc
	# Install
	zydux_exec make -j${ZYDUX_JOBS} install-gcc
	# Install
	zydux_exec make -j${ZYDUX_JOBS} install-target-libgcc
	# Leave dir
	zydux_leave_dir
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	musl
# Brief		Build musl
# ----------------------------------------------------------------------
function cmd_musl()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "BUILD MUSL"
	# Init
	common_init
	# Usefull variables	
	musl_source_dir=$(zydux_source_dir_from_url ${ZYDUX_MUSL_URL})
	#musl_build_dir=${ZYDUX_BUILDS_DIR}/${ZYDUX_SCRIPT_NOEXT}-musl
	# Reset build directory
	#zydux_delete_dir ${musl_build_dir}
	#zydux_ensure_dir_exist ${musl_build_dir}
	# Enter dir
	#zydux_enter_dir ${musl_build_dir} 
	zydux_enter_dir ${musl_source_dir} 
	# Mr Proper
	zydux_exec	make distclean
	# Configure
	zydux_export	CC=${ZYDUX_TARGET}-gcc
	zydux_exec 		${musl_source_dir}/configure \
					--target=${ZYDUX_TARGET} \
					--prefix=/ \
					--with-pkgversion=${ZYDUX_PKGVERSION}

	# Make
	zydux_export CC=${ZYDUX_TARGET}-gcc
	zydux_exec make -j${ZYDUX_JOBS} 
	# Install
	zydux_export DESTDIR=${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET}
	zydux_exec make install	
	# Leave dir
	zydux_leave_dir
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	gcc_2
# Brief		Build gcc step 2
# ----------------------------------------------------------------------
function cmd_gcc_2()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "BUILD GCC FINAL (STEP 2)"
	# Init
	common_init
	# Usefull variables		
	gcc_source_dir=$(zydux_source_dir_from_url ${ZYDUX_GCC_URL})			
	gcc_build_dir=${ZYDUX_BUILDS_DIR}/${ZYDUX_SCRIPT_NOEXT}-gcc_2	
	# Sanity
	zydux_delete_dir ${gcc_build_dir}
	zydux_ensure_dir_exist ${gcc_build_dir}	
	# Enter dir	
	zydux_enter_dir ${gcc_build_dir}
	# Extra args
	extargs=""
	if [ ${ZYDUX_GCC_NO_BOOSTRAP} -eq 1 ]; then
		zydux_log NOTICE "GCC bootstrap disabled !"
		extargs="${extargs}--disable-bootstrap "
	fi
	# Configure	
	zydux_exec		/bin/bash \
					${gcc_source_dir}/configure \
					--build=${ZYDUX_HOST} \
					--host=${ZYDUX_HOST} \
					--target=${ZYDUX_TARGET} \
					--prefix=${ZYDUX_TOOLCHAIN_DIR} \
					--with-sysroot=${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET} \
					--with-pkgversion=${ZYDUX_PKGVERSION} \
					--disable-nls \
					--enable-c99 \
					--enable-long-long \
					--disable-multilib \
					--disable-libmudflap \
					--disable-libmpx \
					--enable-languages=c \
					${extargs}
	# Make
	zydux_exec make -j${ZYDUX_JOBS}
	# Install
	zydux_exec make -j${ZYDUX_JOBS} install
	# Leave dir
	zydux_leave_dir
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	linker
# Brief		gcc_2 seem to remove ld-musl-i386.so.1, WTF ???
# ----------------------------------------------------------------------
function cmd_linker()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "LINK LINKER"
	# Init
	common_init
	# Link linker
	zydux_link_file /lib/libc.so ${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET}/lib/ld-musl-i386.so.1
	# Report
	common_report
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	check
# Brief		Check build
# ----------------------------------------------------------------------
function cmd_check()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "QUICK GCC CHECK"
	# Init
	common_init
	# Get gcc version
	zydux_log INFO "Get GCC version"
	zydux_exec ${ZYDUX_TARGET}-gcc -v	
	# Build dummy program	
	zydux_log INFO "Building dummy program"
	zydux_enter_dir ${ZYDUX_BUILDS_DIR}
	echo "#include <stdio.h>
int main(int argc, char** argv){
	printf(\"Hello World : %d !\n\", argc);
	return 0;
}" > dummy.c
	zydux_exec ${ZYDUX_TARGET}-gcc dummy.c -o dummy
	zydux_ensure_file_exist dummy
	#Ldd
	zydux_export LD_LIBRARY_PATH=${ZYDUX_TOOLCHAIN_DIR}/${ZYDUX_TARGET}/lib:${LD_LIBRARY_PATH}
	zydux_exec ldd dummy
	# Exec
	#zydux_exec ./dummy	
	# Clean
	zydux_delete_file dummy
	zydux_delete_file dummy.c
	zydux_leave_dir
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# **********************************************************************
#                              ENTRY POINT
# **********************************************************************

# Execute command
zydux_cmdline_exec "all" ${@}


