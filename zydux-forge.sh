# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                              FORGE MANAGEMENT
#
# ======================================================================

# Include main library
. $(dirname $(realpath ${0}))/libs/zydux-lib.inc

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
	zydux_delete_dir ${ZYDUX_BUILDS_DIR}
	zydux_delete_dir ${ZYDUX_SOURCES_DIR}
	zydux_delete_dir ${ZYDUX_REPORTS_DIR}	
	zydux_delete_dir ${ZYDUX_TARGET_DIR}	
	zydux_delete_dir ${ZYDUX_TOOLCHAIN_DIR}
	zydux_delete_dir ${ZYDUX_MNT_DIR}
	zydux_delete_file ${ZYDUX_IMG_FILENAME}
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
	[ -d ${ZYDUX_LOGS_DIR} ] && rm -r ${ZYDUX_LOGS_DIR}
}

# ----------------------------------------------------------------------
# Command	backup
# Brief		Backup build directory
# ----------------------------------------------------------------------
function cmd_backup()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "BACKUP"	
	# Filename
	dirname=$(basename  ${ZYDUX_WORK_DIR})
	filename="zydux-build-$(date +"%Y%m%d-%H%M%S").tar.bz2"
	zydux_log MSG "Creating backup from '${dirname}' ($(zydux_size_to_human $(zydux_dir_size ${ZYDUX_WORK_DIR})))..."
	# Enter dir	
	zydux_enter_dir ${ZYDUX_WORK_DIR}/..
	# Compress
	zydux_exec tar -cjf /tmp/${filename} ${dirname}
	# Leave dir
	zydux_leave_dir
	# Moving file
	zydux_move_file /tmp/${filename} ${ZYDUX_WORK_DIR}/${filename}
	# Done
	zydux_log SUCCESS "Backup ready to '${filename}' ($(zydux_size_to_human $(zydux_file_size ${ZYDUX_WORK_DIR}/${filename}))) !"
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	forge_backup
# Brief		Backup zidux-forge source code
# ----------------------------------------------------------------------
function cmd_forge_backup()
{
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "${ZYDUX_FORGE_TITLE} BACKUP"
	# Filename
	dirname=$(basename  ${ZYDUX_BASE_DIR})
	filename=${ZYDUX_FORGE_NAME}-${ZYDUX_FORGE_VERSION}.tar.bz2
	zydux_log MSG "Creating backup from '${dirname}' ($(zydux_size_to_human $(zydux_dir_size ${ZYDUX_BASE_DIR}))) ..."
	# Enter dir	
	zydux_enter_dir ${ZYDUX_BASE_DIR}/..
	# Compress
	zydux_exec tar -cjf ${ZYDUX_WORK_DIR}/${filename} ${dirname}
	# Leave dir
	zydux_leave_dir
	# Done
	zydux_log SUCCESS "Backup ready to '${filename}' ($(zydux_size_to_human $(zydux_file_size ${ZYDUX_WORK_DIR}/${filename}))) !"
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# ----------------------------------------------------------------------
# Command	forge_commit
# Brief		Commit and push zidux-forge source code modification to github
# ----------------------------------------------------------------------
function cmd_forge_commit()
{	
	# Timing reference
	local timeref=$(zydux_tic)
	# Section
	zydux_section "GIT COMMIT"	
	read -p "Modification comment : " comment
	# Enter dir	
	zydux_enter_dir ${ZYDUX_BASE_DIR}
	# Commit	
	zydux_exec git add .
	zydux_exec git commit -m '${comment}'
	zydux_exec git status
	zydux_exec git push
	# Leave dir
	zydux_leave_dir
	# Done
	zydux_log SUCCESS "Done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# Execute command
zydux_cmdline_exec "no-all" ${@}
