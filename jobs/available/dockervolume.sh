#!/bin/bash

set -e

if [ -z "${SCRIPTDIR}" ]; then 
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) This script is not meant to be called by itself"
    exit 1
fi

# For some reason the dictionary gets not exported even though it was declared as such.
# To "fix it" we source .env yet again.
source "${SCRIPTDIR}/.env"

source "${SCRIPTDIR}/lib/utils.sh"

JOBNAME="Docker Volumes"
info "${JOBNAME}" "Running Job"

declare -a REQ_VARS
REQ_VARS[0]=DOCKER_VOLUMES
REQ_VARS[0]=BACKUP_TARGETDIR

checkRequiredEnvVariables "${REQ_VARS[@]}"

for VOLUME_NAME in "${!DOCKER_VOLUMES[@]}"; do

    docker volume ls | grep "${VOLUME_NAME}" || (error "${JOBNAME}" "Couldn't find volume ${VOLUME_NAME}"; exit 1)

    info "${JOBNAME}" "Backing up ${VOLUME_NAME}"
    VOLUME_DST="${DOCKER_VOLUMES[${VOLUME_NAME}]}"
    docker run \
        --mount "type=volume,src=${VOLUME_NAME},dst=${VOLUME_DST}" \
        --name "${VOLUME_NAME}_backup" \
        alpine:latest
    docker cp -a "${VOLUME_NAME}_backup:${VOLUME_DST}" "${BACKUP_TARGETDIR}/${VOLUME_NAME}"
    docker rm "${VOLUME_NAME}_backup"
done
