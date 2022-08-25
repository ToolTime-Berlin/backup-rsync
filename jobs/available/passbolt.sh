#!/bin/bash

set -e

if [ -z "${BACKUP_TARGETDIR}" ]; then 
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) This script is not meant to be called by itself"
    exit 1
fi

source "${SCRIPTDIR}/lib/utils.sh"

JOBNAME="Passbolt"
info "${JOBNAME}" "Running Job"

if [ ! -d /etc/passbolt ]; then 
    error "${JOBNAME}" "Configuration files not found! Is this even a ${JOBNAME} enabled server?"
    exit 1
fi
info "${JOBNAME}" "Copying ${JOBNAME} configuration files to ${BACKUP_TARGETDIR}/"
cp -r --parents /etc/passbolt/gpg /etc/passbolt/passbolt.php "${BACKUP_TARGETDIR}/"
info "${JOBNAME}" "Saving installed packages list"
dpkg -l > "${BACKUP_TARGETDIR}/${JOBNAME}-package.list"
dpkg --get-selections > "${BACKUP_TARGETDIR}/${JOBNAME}-selections.list"
