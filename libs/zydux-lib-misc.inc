# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                           MISCELLANEOUS LIBRARY
#
# ======================================================================

# Round bc result (take care of "." vs "," decimal separator)
# 1  : value
function zydux_round()
{
	local prev=${LC_NUMERIC}
	LC_NUMERIC="en_US.UTF-8"
	printf "%.0f" ${1}
	LC_NUMERIC=${prev}
}

# Check if value is in array
# 1  : value
# 2  : array
# $? : 0=notfound, 1=found
function zydux_in_array() {
  local value
  for value in "${@:2}"; do [[ "${value}" == "${1}" ]] && return 1; done
  return 0
}


# Init tic counter
function zydux_tic()
{
	echo $(date +%s)
}

# Get elapsed time in seconds
# 1 : tic value
function zydux_toc()
{
	local start=${1}
	end=$(date +%s)
	echo $((end-start))
}

# Convert second to human representation (x h, x min, x sec)
# 1 : Seconds count
function zydux_sec_to_human()
{
	local val=${1}
	local day=0
	local hour=0
	local min=0
	local sec=${1}
	if [ ${val} -gt 59 ]; then		
		min=$((sec/60))		
		sec=$((sec%60))
		if [ ${min} -gt 59 ]; then
			hour=$((min/60))
			min=$((min%60))			
			if [ ${hour} -gt 23 ]; then				
				day=$((hour/24))			
				hour=$((hour%24))	
			fi
		fi
	fi
	local str=""
	[ ${day} -gt 0 ] && str="${day} d"
	[ ${hour} -gt 0 ] && str="${str} ${hour} h"
	[ ${min} -gt 0 ] && str="${str} ${min} m"
	[ ${sec} -gt 0 ] && str="${str} ${sec} s"
	[ "${str}" == "" ] && str="0 s"
	echo $str
	
}

# Convert size to human representation
# 1 : Size in bytes
function zydux_size_to_human()
{
	local scale=2
	local size=${1}	
	[ "${size}" == "" ] && size=0	
	if [ ${size} -gt 1099511627776 ]; then	
		v="$(echo "scale=${scale};${size}/1099511627776"|bc) TB"
	elif [ ${size} -gt 1073741824 ]; then	
		v="$(echo "scale=${scale};${size}/1073741824"|bc) GB"
	elif [ ${size} -gt 1048576 ]; then
		v="$(echo "scale=${scale};${size}/1048576"|bc) MB"
	elif [ ${size} -gt 1024 ]; then
		v="$(echo "scale=${scale};${size}/1024"|bc) KB"
	else
		v="${size} B"
	fi	
	echo "${v}"
}
