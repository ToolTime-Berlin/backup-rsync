#!/bin/bash

SCRIPT=$(readlink -f "${BASH_SOURCE:-$0}")
export SCRIPTDIR=$(dirname "${SCRIPT}")

export GREEN=$(tput setaf 2)
export RED=$(tput setaf 1)
export NC=$(tput sgr0)
export QUIET=false
BACKUP_PATH_PATTERN="daily/$(date +%A)"
export NOW=$(date +"%Y%m%d-%H%M")
BACKUP_BASEDIR="/tmp/tooltime-backup-${NOW}"

declare -a REQ_VARS
REQ_VARS[0]=RSYNC_TARGET_HOST
REQ_VARS[1]=RSYNC_TARGET_PATH
REQ_VARS[2]=RSYNC_TARGET_USER
REQ_VARS[3]=LOG_FILE

source "${SCRIPTDIR}/.env"
source "${SCRIPTDIR}/lib/utils.sh"

trap error_report ERR
trap cleanup EXIT

usage() {
    QUIET=false
    local LOG
    if [ "$1" -eq 0 ]; then LOG=info; else LOG=error; fi
    $LOG "Usage: $0 [-hdwmq] [-c sub/path] " 1>&2
    print "        --help        Show this usage message."
    print "        -q, --quiet   Surpress output"
    print "        -h, --hourly  Create a backup structure based on the current hour."
    print "        -d, --daily   Same as -h but with day of the week."
    print "        -w, --weekly  Same as -h but with calendar week number."
    print "        -m, --monthly Same as -h but with name of month."
    print "        -c, --custom  Provide a custom pattern for a subpath."
    exit ${1:-1} 
}

cleanup() {
    info "Remove temporary files if any"
    if [ -d "${BACKUP_BASEDIR}" ]; then
        rm -rf "${BACKUP_BASEDIR}";
    fi
    exit
}

error_report() {
    error "There was an error on line $(caller)"
}

ARGS=$(getopt -o hdwmc:q --long hourly,daily,weekly,monthly,custom:,quiet,help -- "$@" 2>/dev/null)
if [ $? -ne 0 ]; then
    error "Invalid option or missing arg!"
    usage
fi

set -e

eval set -- "$ARGS"
while [ -n "$1" ]; do
    case "$1" in
        --help)         usage 0; shift;;
        -h | --hourly)  BACKUP_PATH_PATTERN="hourly/$(date +%H)"; shift;;
        -d | --daily)   shift;;
        -w | --weekly)  BACKUP_PATH_PATTERN="weekly/$(date +%U)"; shift;;
        -m | --monthly) BACKUP_PATH_PATTERN="monthly/$(date +%B)"; shift;;
        -c | --custom)  BACKUP_PATH_PATTERN="$2"; shift; shift;;
        -q | --quiet)   QUIET=true; shift;;
        --)             shift; break;;
    esac
done

banner
checkRequiredEnvVariables "${REQ_VARS[@]}"

info "-----------------------------------"
info "Starting backup on $(date +"%d.%m.%Y %H:%M")"
info "-----------------------------------"


export BACKUP_TARGETDIR="${BACKUP_BASEDIR}/${MACHINE_NAME}/${BACKUP_PATH_PATTERN}"

if [ ! -d "${BACKUP_TARGETDIR}" ]; then
    info "Creating temporary directory '${BACKUP_TARGETDIR}'"
    mkdir -p "${BACKUP_TARGETDIR}"
fi

info "Backup target is ${BACKUP_PATH_PATTERN}"

ALL_JOBS=$(find "${SCRIPTDIR}/jobs/enabled" -name '*.sh' -executable)

if [ -z "${ALL_JOBS}" ]; then
    error "No jobs defined - enable one by linking one or more of `./jobs/available` to `./jobs/enabled`."
    exit 1
fi

for JOB in ${ALL_JOBS}; do $JOB; done

while [ -n "$(pgrep 'rsync ')" ]; do
  sleep 60
done

declare -a RSYNC_PARAMS
RSYNC_PARAMS=(-rlptgoz --relative --log-file="${LOG_FILE}")
if [ "${QUIET}" = false ]; then
    RSYNC_PARAMS=( -vv "${RSYNC_PARAMS[@]}" --progress )
fi
info "Syncing files to ${RSYNC_TARGET_USER}@${RSYNC_TARGET_HOST}:${RSYNC_TARGET_PATH}/${BACKUP_PATH_PATTERN}"
rsync "${RSYNC_PARAMS[@]}" "${BACKUP_BASEDIR}/./${MACHINE_NAME}/${BACKUP_PATH_PATTERN}" "${RSYNC_TARGET_USER}@${RSYNC_TARGET_HOST}:${RSYNC_TARGET_PATH}/"

info "SUCCESS! Backup finished."
