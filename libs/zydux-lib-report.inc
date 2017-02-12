# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#
#                             REPORT LIBRARY
#
# ======================================================================
# TODO :
# * Handle switch for with or without symb link, beacause of busybox link
#   vs too much link in kernel module sources
# ======================================================================

# Create files snapshot
# 1 : directory
# 2 : snapshot filename
function zydux_report_snapshot()
{
	find ${1}|sort > ${2}	
}

# Create files snapshot
# 1 : directory
# 2 : snapshot filename
# 3 : report
function zydux_report_change()
{
	# Timing reference
	local timeref=$(zydux_tic)	
	zydux_log MSG "Checking for changes to report..."
	local report=()
	local content=()
	local snapshot=()
	# Load content and snapshot
	[ -d ${1} ] && mapfile -t content < <(find ${1}|sort)
	[ -f ${2} ] && mapfile -t snapshot < <(cat ${2})	
	local count=${#content[@]}
	# check
	local added=0	
	for filename in "${content[@]}"
	do			
		[[ " ${snapshot[@]} " =~ " ${filename} " ]] && continue		
		if [ -L ${filename} ]; then
			report+=("L ${filename} -> $(readlink ${filename})")
		elif [ -f ${filename} ]; then
			report+=("F ${filename}")
		elif [ -d ${filename} ]; then
			report+=("D ${filename}")
		else
			report+=("? ${filename}")
		fi
		added=$((added+1))
	done
	# Saving report
	printf "%d/%d new files ($(zydux_sec_to_human $(zydux_toc ${timeref})))\n" ${added} ${count} > ${3}
	printf "%s\n" "${report[@]}" >> ${3}
	zydux_log MSG "${added}/${count} elements are added (Report build in $(zydux_sec_to_human $(zydux_toc ${timeref}))) !"

}
