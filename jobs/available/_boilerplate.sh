#!/bin/bash

set -e

if [ -z "${SCRIPTDIR}" ]; then 
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) This script is not meant to be called by itself"
    exit 1
fi

source "${SCRIPTDIR}/lib/utils.sh"

JOBNAME="My Job"
info "${JOBNAME}" "Running Job"

# Put any files you like to backup in ${BACKUP_TARGETDIR} in order to get it rsynced.
# Use `[info|error|print] "${JOBNAME}" "Some messsage"` to log/echo to stdout. 
# Just exit with any error code if necessary and all files in ${BACKUP_TARGETDIR}
# will get removed automatically.
# You need to make your job executable!
