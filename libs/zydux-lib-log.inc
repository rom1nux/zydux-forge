# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                                LOG LIBRARY
#
# ======================================================================

function zydux_lib_log_init()
{
	# Adjut display color if need
	if [ ${ZYDUX_COLOR_ENABLED} -eq 1 ]; then
		ZYDUX_COLOR_RESET="\033[0m"
		ZYDUX_COLOR_INFO="\033[1;34m"		# Blue
		ZYDUX_COLOR_STRONG="\033[1;37m"		# White
		ZYDUX_COLOR_SUCCESS="\033[1;32m"	# Green
		ZYDUX_COLOR_NOTICE="\033[1;35m"		# Purple
		ZYDUX_COLOR_WARNING="\033[1;33m"	# Yellow
		ZYDUX_COLOR_ERROR="\033[1;31m"		# Red	
		ZYDUX_COLOR_EXEC="\033[1;37m"		# White
		ZYDUX_COLOR_EXPORT="\033[1;37m"		# White
		ZYDUX_COLOR_VERBOSE="\033[0;37m"	# Gray
		ZYDUX_COLOR_DEBUG="\033[0;36m"		# Cyan		
	fi
}

# Log message
# 1 : type (MSG|STRONG|INFO|SUCCESS|NOTICE|WARNING|ERROR|EXEC|EXPORT|VERBOSE|DEBUG)
# 2 : message
function zydux_log()
{
	# Precompute colors and tag
	case "${1}" in
		MSG) 		tag=;			prefix="";			cs=; 						ce=	;;
		STRONG) 	tag="";			prefix="";			cs=${ZYDUX_COLOR_STRONG}; 	ce=${ZYDUX_COLOR_RESET}	;;					
		INFO) 		tag="[${1}]";	prefix="";			cs=${ZYDUX_COLOR_INFO}; 	ce=${ZYDUX_COLOR_RESET}	;;	
		SUCCESS) 	tag="[${1}]";	prefix="";			cs=${ZYDUX_COLOR_SUCCESS}; 	ce=${ZYDUX_COLOR_RESET}	;;
		NOTICE)		tag="[${1}]";	prefix="NOTICE:";	cs=${ZYDUX_COLOR_NOTICE}; 	ce=${ZYDUX_COLOR_RESET}	;;
		WARNING)	tag="[${1}]";	prefix="WARNING: ";	cs=${ZYDUX_COLOR_WARNING}; 	ce=${ZYDUX_COLOR_RESET}	;;
		ERROR) 		tag="[${1}]";	prefix="ERROR: ";	cs=${ZYDUX_COLOR_ERROR}; 	ce=${ZYDUX_COLOR_RESET}	;;
		EXEC) 		tag="[${1}]";	prefix="EXEC: ";	cs=${ZYDUX_COLOR_EXEC}; 	ce=${ZYDUX_COLOR_RESET}	;;	
		EXPORT) 	tag="[${1}]";	prefix="EXPORT: ";	cs=${ZYDUX_COLOR_EXPORT}; 	ce=${ZYDUX_COLOR_RESET}	;;	
		VERBOSE)
					[ $ZYDUX_VERBOSE_ENABLED -lt 1 ] && return
					tag="";			prefix="";			cs=${ZYDUX_COLOR_VERBOSE}; 	ce=${ZYDUX_COLOR_RESET}	;;
		DEBUG) 		
					[ $ZYDUX_DEBUG_ENABLED -lt 1 ] && return
					tag="";			prefix="";			cs=${ZYDUX_COLOR_DEBUG}; 	ce=${ZYDUX_COLOR_RESET}	;;
		*)
	esac
	shift
	# Print on console
	echo -e "${cs}${prefix}${@}${ce}"
	# Print in log file
	if [ ${ZYDUX_LOG_ENABLED} -eq 1 ]; then
		printf "%-20s %-10s ${@}\n" "$(date +"${ZYDUX_LOG_DATE_FORMAT}")" "${tag}" >> ${ZYDUX_LOG_FILENAME}
	fi
}

# Print error message and exit
#  1 : message
function zydux_die()
{
	if [ "${ZYDUX_CMDLINE_CMD}" == "" ]; then
		zydux_log ERROR "${@}"
	else
		zydux_log ERROR "${@} [${ZYDUX_CMDLINE_CMD}]"
	fi
	exit 1
}

# Print center string
#  1 : type of message, see zydux_log()
#  2 : message
function zydux_center()
{
	zydux_log ${1} "$(printf "%*s" $(( (${#2} + ${ZYDUX_TERM_COLS}) / 2)) "${2}")"
}

# Print a bar
#  1 : type of message, see zydux_log()
#  2 : Symbol of bar
#  3 : Size of bar
function zydux_bar()
{
	zydux_log ${1} "$(printf "%${3}s" |tr " " "${2}")"
}

# Display section
#  1 : Title of section
function zydux_section()
{	
	zydux_bar		INFO "=" ${ZYDUX_TERM_COLS}
	zydux_center 	INFO "${@}"
	zydux_bar 		INFO "=" ${ZYDUX_TERM_COLS}
}

# Display banner
function zydux_banner()
{
	# Clear log if need
	[ ${ZYDUX_LOG_CLEAR_AT_STARTUP} -eq 1 ] && cat /dev/null > ${ZYDUX_LOG_FILENAME}
	# Print banner
	zydux_center MSG " _____ __ __ ____  _____ __ __ "
	zydux_center MSG "|__   |  |  |    \|  |  |  |  |"
	zydux_center MSG "|   __|\   /|  |  |  |  |-   -|"
	zydux_center MSG "|_____| |_| |____/|_____|__|__|"
	zydux_center MSG ""	
	zydux_center MSG "${ZYDUX_FORGE_TITLE} V${ZYDUX_FORGE_VERSION}"
	zydux_center MSG "${ZYDUX_FORGE_COPYRIGHT}"
	zydux_center MSG ""
}


# Display list
#  1 : type
#  2 : list
#  3 : separator
#  4 : bullet
function zydux_log_list()
{
	echo "${2}" | while read -r -d "${3}" line; do
		zydux_log ${1} "${4}${line}"
	done
}

# Display numbered list
#  1 : type
#  2 : list
#  3 : separator
function zydux_log_num_list()
{
	echo "${2}" | while read -r -d "${3}" line; do
		num=$(( num + 1 ))	
		zydux_log ${1} "$(printf "%3d" ${num}) : ${line}"
	done
}

# Display file list
#  1 : type
#  2 : list
#  3 : separator
#  4 : trim basedir
function zydux_log_file_list()
{
	echo "${2}" | while read -r -d "${3}" filename; do
		num=$(( num + 1 ))	
		f="$(realpath ${filename})"
		zydux_log ${1} "$(printf "%3d" ${num}) : ${f#${4}}"
	done
}
