# ======================================================================
#                       _____ __ __ ____  _____ __ __ 
#                      |__   |  |  |    \|  |  |  |  |
#                      |   __|\   /|  |  |  |  |-   -|
#                      |_____| |_| |____/|_____|__|__|
#                        Copyright (c) 2017 zydux.org
#                                MAIN LIBRARY
#
# ======================================================================

# Turn off hashing
set +h

# Script info
ZYDUX_FORGE_TITLE="ZYDUX FORGE"
ZYDUX_FORGE_NAME="zydux-forge"
ZYDUX_FORGE_VERSION="0.46"
ZYDUX_FORGE_COPYRIGHT="Copyright (c) 2017 zydux.org"

# Script
ZYDUX_SCRIPT=$(basename ${0})
ZYDUX_SCRIPT_NOEXT=${ZYDUX_SCRIPT%.*}

# Directories
ZYDUX_BASE_DIR=$(dirname $(realpath ${0}))
ZYDUX_LIBS_DIR=${ZYDUX_BASE_DIR}/libs
ZYDUX_RESOURCES_DIR=${ZYDUX_BASE_DIR}/res
ZYDUX_WORK_DIR=$(pwd)
ZYDUX_DOWNLOADS_DIR=${ZYDUX_WORK_DIR}/downloads
ZYDUX_SOURCES_DIR=${ZYDUX_WORK_DIR}/sources
ZYDUX_BUILDS_DIR=${ZYDUX_WORK_DIR}/builds
ZYDUX_TOOLCHAIN_DIR=${ZYDUX_WORK_DIR}/toolchain
ZYDUX_REPORTS_DIR=${ZYDUX_WORK_DIR}/reports
ZYDUX_TARGET_DIR=${ZYDUX_WORK_DIR}/target
ZYDUX_LOGS_DIR=${ZYDUX_WORK_DIR}/logs
ZYDUX_MNT_DIR=${ZYDUX_WORK_DIR}/mnt

# Files
ZYDUX_DEFAULT_CONFIG_FILE=${ZYDUX_RESOURCES_DIR}/zydux-default-config.inc
ZYDUX_CONFIG_FILE=${ZYDUX_WORK_DIR}/zydux-config.inc
ZYDUX_LOG_FILENAME=${ZYDUX_LOGS_DIR}/${ZYDUX_SCRIPT_NOEXT}.log
ZYDUX_SNAPSHOT_FILENAME=${ZYDUX_REPORTS_DIR}/${ZYDUX_SCRIPT_NOEXT}.snapshot
ZYDUX_IMG_FILENAME=${ZYDUX_WORK_DIR}/zydux.img

# Host
ZYDUX_HOST=$(gcc -v 2>&1|grep Target:|cut -d" " -f 2)
ZYDUX_CORES=$(grep -c ^processor /proc/cpuinfo)
ZYDUX_PKG_VERSION=${ZYDUX_FORGE_NAME}-${ZYDUX_FORGE_VERSION}

# Stuffs
ZYDUX_TERM_COLS=$(tput cols)
ZYDUX_TERM_LINES=$(tput lines)

# Default minimal config
ZYDUX_COLOR_ENABLED=1
ZYDUX_VERBOSE_ENABLED=0
ZYDUX_DEBUG_ENABLED=0
ZYDUX_LOG_ENABLED=0
ZYDUX_LOG_CLEAR_AT_STARTUP=0

# Command line
ZYDUX_CMDLINE_OPTS=()
ZYDUX_CMDLINE_ARGS=()
ZYDUX_CMDLINE_CMD=""

# Includes
. ${ZYDUX_LIBS_DIR}/zydux-lib-log.inc
. ${ZYDUX_LIBS_DIR}/zydux-lib-file.inc
. ${ZYDUX_LIBS_DIR}/zydux-lib-src.inc
. ${ZYDUX_LIBS_DIR}/zydux-lib-misc.inc
. ${ZYDUX_LIBS_DIR}/zydux-lib-cmd.inc
. ${ZYDUX_LIBS_DIR}/zydux-lib-exec.inc
. ${ZYDUX_LIBS_DIR}/zydux-lib-report.inc

# Handle default config file
if ! [ -f ${ZYDUX_CONFIG_FILE} ]; then
	zydux_lib_log_init	
	zydux_banner
	zydux_log NOTICE "No configuration file found, so I will create a default one for you in :"
	zydux_log NOTICE "${ZYDUX_CONFIG_FILE}"
	zydux_log NOTICE "Please check and/or adjust configuration file and restart command"
	zydux_copy_file ${ZYDUX_DEFAULT_CONFIG_FILE} ${ZYDUX_CONFIG_FILE}
	exit 1
fi

# Load config
. ${ZYDUX_CONFIG_FILE}

# Create log directory
! [ -d ${ZYDUX_LOGS_DIR} ] && mkdir -p ${ZYDUX_LOGS_DIR}

# Jobs
ZYDUX_JOBS=$(zydux_round $(echo "${ZYDUX_CORES}*${ZYDUX_JOBS_PER_CORE}"|bc -l))

# Init libraries
zydux_lib_log_init

# Banner
zydux_banner




