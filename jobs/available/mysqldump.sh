#!/bin/bash

set -e

if [ -z "${SCRIPTDIR}" ]; then 
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) This script is not meant to be called by itself"
    exit 1
fi

source "${SCRIPTDIR}/lib/utils.sh"

JOBNAME="MySQL Dump"
declare -a REQ_VARS
REQ_VARS[0]=MYSQL_USERNAME
REQ_VARS[1]=MYSQL_PASSWORD
REQ_VARS[2]=MYSQL_DATABASES

info "${JOBNAME}" "Running Job"
checkRequiredEnvVariables "${REQ_VARS[@]}"

for DATABASE in ${MYSQL_DATABASES}; do
    BACKUP_FILE="${BACKUP_TARGETDIR}/db-${DATABASE}-${NOW}.sql"
    info "${JOBNAME}" "Dumping database '${DATABASE}' to '${BACKUP_FILE}'"
    MYSQL_PWD="${MYSQL_PASSWORD}" 
    mysqldump \
        -u "${MYSQL_USERNAME}" \
        --skip-lock-tables \
        --single-transaction \
        --no-tablespaces \
        "${DATABASE}" > "${BACKUP_FILE}" 2>&1 | tee -a "${LOG_FILE}"
    if [ $? -ne 0 ]; then
        error "${JOBNAME}" "Couldn't dump ${DATABASE} - mysqldump did not succeed."
        exit 1
    fi
done