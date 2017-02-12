# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#
#                              FILE LIBRARY
#
# ======================================================================

# **********************************************************************
#                           COMMONS FUNCTIONS
# **********************************************************************

# Change right on directory
# 1 : rights
# 2 : file/directory
# 3 : recursive|non-recursive|<empty>
function zydux_chmod()
{	
	if [ -d "${2}" ]; then
		local opt=""
		zydux_log VERBOSE "Set right '${1}' on directory '${2}'..."
		[ "${3}" == "recursive" ] && opt="-R"
		chmod ${opt} "${1}" "${2}"
		[ $? -ne 0 ] && zydux_die "Could not set rights on directory '${2}' !"
	fi
}

# **********************************************************************
#                           DIRECTORY FUNCTIONS
# **********************************************************************

# Create directory if is need
# 1  : directory
function zydux_ensure_dir_exist()
{
	if ! [ -d "${1}" ]; then
		zydux_log VERBOSE "Creating directory '${1}'..."
		mkdir -p "${1}"
		[ $? -ne 0 ] && zydux_die "Could not create directory '${1}' !"
	fi	
}

# Delete dir if exist
# 1  : directory
function zydux_delete_dir()
{
	if [ -d "${1}" ]; then
		zydux_log VERBOSE "Delete directory '${1}'..."
		rm -r -f "${1}"
		[ $? -ne 0 ] && zydux_die "Could not remove directory '${1}' !"
	fi
}

# Get dir size in bytes
# 1  : directory
function zydux_dir_size()
{
	if [ -d "${1}" ]; then
		du -sb "${1}"|cut -f1
	else
		echo "0"
	fi
}


# Add directory to front of PATH if is need
# 1  : directory
function zydux_add_dir_to_front_path()
{
	echo "$PATH"|grep -q "${1}"
	if [ $? -ne 0 ]; then
		zydux_log VERBOSE "Add directory '${1}' to PATH..."
		export PATH=${1}:${PATH}
		zydux_log DEBUG "PATH=${PATH}"
	fi
}

# Entering (cd) directory
# 1  : directory
function zydux_enter_dir()
{
	zydux_log VERBOSE "Leaving '$(pwd)'..."	
	pushd ${1} > /dev/null
	[ $? -ne 0 ] && zydux_die "Could not enter to directory '${1}' !"
	zydux_log VERBOSE "Entering to '$(pwd)'..."
}

# Return to previous entered (cd) directory
function zydux_leave_dir()
{
	zydux_log VERBOSE "Leaving '$(pwd)'..."	
	popd >> /dev/null
	[ $? -ne 0 ] && zydux_die "Could not leave directory '$(pwd)' !"
	zydux_log VERBOSE "Returning to '$(pwd)'..."
}

# **********************************************************************
#                           FILE FUNCTIONS
# **********************************************************************

# Be sure file exist
# 1  : filename
function zydux_ensure_file_exist()
{
	! [ -f "${1}" ] && zydux_die "File '${1}' not found !'"		
}

# Delete file if exist
# 1  : filename
function zydux_delete_file()
{
	if [ -f "${1}" ]; then
		zydux_log VERBOSE "Delete file '${1}'..."
		rm "${1}"
		[ $? -ne 0 ] && zydux_die "Could not remove file '${1}' !"
	fi
}

# Create link to file
# 1  : filename
# 2  : link
function zydux_link_file()
{
	if ! [ -L "${2}" ]; then
		zydux_log VERBOSE "Create symlink '${2}' pointing to ${1}..."
		ln -s ${1} ${2}
		[ $? -ne 0 ] && zydux_die "Could not create simlink '${2}' pointing to file '${1}' !"
	fi
}

# Change timestamp of file
# 1  : filename
function zydux_touch_file()
{
	zydux_log VERBOSE "Touching file ${1}..."
	touch ${1}
	[ $? -ne 0 ] && zydux_die "Could not touch file '${1}' !"
}

# Install file in directory (with same attribut)
# 1 : source filename
# 2 : destination directory
function zydux_install_file()
{
	dest=${2}/$(basename ${1})
	if ! [ -f ${dest} ]; then
		zydux_log VERBOSE "Installing file ${1} to ${2}..."	
		install ${1} ${2}
		[ $? -ne 0 ] && zydux_die "Could install file '${1}' to ${2} !"
	fi
}

# Copy file
# 1 : source filename
# 2 : destination filename
function zydux_copy_file()
{
	if ! [ -f ${2} ]; then	
		zydux_log VERBOSE "Copying file ${1} to ${2}..."	
		! [ -f ${1} ] && zydux_die "File '${1}' not found !"
		cp ${1} ${2}
		[ $? -ne 0 ] && zydux_die "Could copy file '${1}' to ${2} !"
	fi
}

# Move file
# 1 : source filename
# 2 : destination filename
function zydux_move_file()
{
	if ! [ -f ${2} ]; then	
		zydux_log VERBOSE "Moving file ${1} to ${2}..."	
		! [ -f ${1} ] && zydux_die "File '${1}' not found !"
		cp ${1} ${2}
		[ $? -ne 0 ] && zydux_die "Could move file '${1}' to ${2} !"
	fi
}

# Get file size in bytes
#   1  : filename
function zydux_file_size()
{
	if [ -f "${1}" ]; then
		stat -c%s "${1}"
	else
		echo "0"
	fi	
}

# Get file name without extention
# 1  : filename
function zydux_file_name_without_ext()
{
	filename=$(basename ${1})
	name=${filename%.*}
	if ! [ "${name##*.}" = "tar" ]; then
		echo ${name}
	else
		echo ${name%.*}
	fi
		
}
