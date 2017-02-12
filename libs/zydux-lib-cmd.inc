# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                              COMMAND LIBRARY
#
# ======================================================================

# Execute command
# 1 : all|no-all
# @ : Command line arguments
function zydux_cmdline_exec()
{
	local allow_all=${1}
	shift
	# Split commands, args and options
	local iopts=0
	local iargs=0
	local arg
	for arg in "$@"
	do	
		if [ "${arg:0:1}" == "-" ]; then
			# Handle options
			case ${arg} in
				"--verbose"|"-v") 		ZYDUX_VERBOSE_ENABLED=1 ;;
				"--debug"|"-d") 		ZYDUX_DEBUG_ENABLED=1 ;;
				*) 
					ZYDUX_CMDLINE_OPTS[${iopts}]=${arg}
					iopts=$((iopts+1))
			esac
		else
			if [ -z "${ZYDUX_CMDLINE_CMD}" ]; then
				# Main command
				ZYDUX_CMDLINE_CMD=${arg}
			else
				# Handle args
				ZYDUX_CMDLINE_ARGS[${iargs}]=${arg}
				iargs=$((iargs+1))
			fi
		fi
	done
	# Debug
	zydux_log DEBUG "Cmd  : ${ZYDUX_CMDLINE_CMD}"
	zydux_log DEBUG "Opts : ${ZYDUX_CMDLINE_OPTS[@]}"
	zydux_log DEBUG "Args : ${ZYDUX_CMDLINE_ARGS[@]}"
	# Call
	case "${ZYDUX_CMDLINE_CMD}" in
		""|"help"|"?" ) 
			zydux_cmdline_help ${allow_all} ;;
		"resume" ) 
			[ "${allow_all}" != "all" ] && zydux_die "Unknown command '${ZYDUX_CMDLINE_CMD}' !"
			zydux_cmdline_resume ;;
		"all" ) 
			[ "${allow_all}" != "all" ] && zydux_die "Unknown command '${ZYDUX_CMDLINE_CMD}' !"
			zydux_cmdline_all ;;
		*) 
			zydux_cmdline_call ;;
	esac
}

# Show common command line help
# 1 : all|no-all
function zydux_cmdline_help()
{
	local cmds cmds i
	# Loading command and brief
	mapfile -t cmds < <( grep "^# Command" $0|awk '{print substr($0, index($0, $3))}' )
	mapfile -t briefs < <( grep "^# Brief" $0|awk '{print substr($0, index($0, $3))}' )
	# Show message
	zydux_log MSG "Usage"
	zydux_log MSG ""
	zydux_log MSG "  $(basename ${0}) [options] <command>"
	zydux_log MSG ""
	zydux_log MSG "Options"
	zydux_log MSG ""
	zydux_log MSG "  --verbose  -v  : Show detail message"
	zydux_log MSG "  --debug    -d  : Show debug message"
	zydux_log MSG ""
	zydux_log MSG "Commands"
	zydux_log MSG ""
	zydux_log MSG "$(printf " *%-14s : %s\n" "help" "Show this help")"
	for (( i=0; i<${#cmds[@]}; i++ )); 
	do
		zydux_log MSG "$(printf "  %-14s : %s\n" "${cmds[i]}" "${briefs[i]}")"
	done
	if [ "${allow_all}" == "all" ]; then
		zydux_log MSG "$(printf " *%-14s : %s\n" "all" "Execute all command in order")"
		zydux_log MSG "$(printf " *%-14s : %s\n" "resume" "Execute all command in order start at specific command")"
	fi
	zydux_log MSG ""
}

# Execute all command in order start at specific command
function zydux_cmdline_resume()
{
	local cmds i
	# Load commads
	mapfile -t cmds < <( grep "^# Command" $0|awk '{print substr($0, index($0, $3))}' )
	mapfile -t briefs < <( grep "^# Brief" $0|awk '{print substr($0, index($0, $3))}' )
	# Check args
	if [ ${#ZYDUX_CMDLINE_ARGS[@]} -lt 1 ]; then
		zydux_log MSG "Usage"
		zydux_log MSG ""
		zydux_log MSG "  $(basename ${0}) [options] resume <command>"
		zydux_log MSG ""
		zydux_log MSG "Commands"
		zydux_log MSG ""
		for (( i=0; i<${#cmds[@]}; i++ )); 
		do
			zydux_log MSG "$(printf "  %-14s : %s\n" "${cmds[i]}" "${briefs[i]}")"
		done
		zydux_log MSG ""		
		exit 1
	fi	
	# Timing reference
	local timeref=$(zydux_tic)
	# Extract command and function
	local cmd=${ZYDUX_CMDLINE_ARGS[0]} 	
	local func="cmd_${cmd}"
	local skip=1	
	# Remove first element
	ZYDUX_CMDLINE_ARGS=("${ZYDUX_CMDLINE_ARGS[@]:1}")
	# Check if step exist
	type "${func}" 2>/dev/null 1>/dev/null	
	[ $? -ne 0 ] && zydux_die "Unknown command '${cmd}' !"
	# Resumable loop
	for (( i=0; i<${#cmds[@]}; i++ )); 
	do
		if [ ${skip} -eq 1 ]; then
			[ "${cmds[i]}" != "${cmd}" ] && continue
			skip=0
		fi
		ZYDUX_CMDLINE_CMD=${cmds[i]}
		zydux_cmdline_call
	done
	# Done
	zydux_log SUCCESS "Commands from '${cmd}' done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# Execute all command in order
function zydux_cmdline_all()
{
	local cmds i
	# Timing reference
	local timeref=$(zydux_tic)	
	# Load commads
	mapfile -t cmds < <( grep "^# Command" $0|awk '{print substr($0, index($0, $3))}' )
	# Full loop
	for (( i=0; i<${#cmds[@]}; i++ )); 
	do
		ZYDUX_CMDLINE_CMD=${cmds[i]}
		zydux_cmdline_call
	done
	# Done
	zydux_log SUCCESS "All commands done in $(zydux_sec_to_human $(zydux_toc ${timeref})) !"
}

# Call function of command
function zydux_cmdline_call()
{
	local cmd="${ZYDUX_CMDLINE_CMD}"
	local func="cmd_${cmd}"
	type "${func}" 2>/dev/null 1>/dev/null	
	[ $? -ne 0 ] && zydux_die "Unknown command '${cmd}' !"
	zydux_log DEBUG "Executing function '${func}'..."
	${func}
}
