# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#
#                         SOURCE MANAGEMENT LIBRARY
#
# ======================================================================

# Download a file from url if need and keep in cache
# 1 : url
function zydux_download_source()
{	
	[ -z ${1} ] && zydux_die "Filename to download is not set !"
	# Extract filename
	filename=$(basename ${1})
	filepath=${ZYDUX_DOWNLOADS_DIR}/${filename}	
	# check if file already downloaded
	if [ -f ${filepath} ]; then
		zydux_log MSG "File '${filename}' already downloaded !"
		return 0
	fi
	# Be sure downloads directory exists
	zydux_ensure_dir_exist ${ZYDUX_DOWNLOADS_DIR}
	# Download
	zydux_delete_file ${filename}
	zydux_log MSG "Downloading '${filename}'..."
	wget "${1}" -O ${filepath}
	[ $? -ne 0 ] && zydux_die "Could not download file '${1}' to '${filepath}' !"
}

# Extract a file from url and keep in cache
# 1 : url
function zydux_extract_source()
{	
	# Extract filename
	filename=$(basename ${1})
	srcfile=${ZYDUX_DOWNLOADS_DIR}/${filename}
	destdir=${ZYDUX_SOURCES_DIR}/$(zydux_file_name_without_ext ${filename})
	# Check source
	zydux_ensure_file_exist "${srcfile}"
	if [ -d ${destdir} ]; then
		zydux_log MSG "File '${filename}' already extracted !"
	else	
		# Be sure sources directory exists
		zydux_ensure_dir_exist ${ZYDUX_SOURCES_DIR}
		# extracting
		zydux_delete_dir ${destdir}
		zydux_enter_dir ${ZYDUX_SOURCES_DIR}
		zydux_log MSG "Extracting '${filename}'..."
		tar -xf ${srcfile}
		[ $? -ne 0 ] && zydux_die "Could not extract file '${srcfile}' to ${ZYDUX_SOURCES_DIR} !"
		zydux_leave_dir
	fi
	#zydux_log MSG " $(zydux_size_to_human $(zydux_file_size ${srcfile})) inflate to $(zydux_size_to_human $(zydux_dir_size ${destdir}))"
}

# Get source directory from URL
# 1 : url
function zydux_source_dir_from_url()
{
	echo ${ZYDUX_SOURCES_DIR}/$(zydux_file_name_without_ext $(basename ${1}))
}

# Get source version from URL
# 1 : url
function zydux_source_version_from_url()
{
	echo $(zydux_file_name_without_ext $(basename ${1}))|cut -d"-" -f 2
}
