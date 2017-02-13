# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                               EXEC LIBRARY
#
# ======================================================================

function zydux_export()
{	
	for arg in ${@}; do
		zydux_log EXPORT "${arg}"
		eval export ${arg}
	done
}
	
function zydux_exec()
{	
	# Timing reference
	local timeref=$(zydux_tic)	
	# Export variables
	local cmd=""
	for arg in "${@}"; do
			cmd="${cmd}${arg} "
			#echo ">>> $arg"
	done	
	zydux_log DEBUG "$(env)"
	# Log command line
	zydux_log EXEC "${cmd}"
	# Run command line
	${cmd} 2>&1 | while IFS=\n read -r line; do
		zydux_log MSG "${line}"
	done
	# Check error
	[ ${PIPESTATUS[0]} -ne 0 ] && zydux_die "Could not execute '${cmd}' !"
	#[ ${?} -ne 0 ] && zydux_die "Could not read command output '${cmd}' !"
	# Done
	zydux_log MSG "Executed in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}
