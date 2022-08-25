#!/bin/bash

function checkRequiredEnvVariables() {
    for VAR in "$@"; do
        if [ -z "${!VAR}" ]; then
            error "You need to setup required environment variables!"
            print "You need to define the following environments variable (preferable in ${SCRIPTDIR}/.env) in order to run ${GREEN}${JOBNAME}${NC}"
            for REQ_VAR in "$@"; do
                print "* ${REQ_VAR}"
            done
            exit 1
        fi
    done
}

function banner() {
    if [ "${QUIET}" = true ]; then return; fi 
    echo
    echo " ${GREEN} ____ ____ ____ ____ ____ ____ ____ ____ ${NC}"
    echo " ${GREEN}||T |||o |||o |||l |||T |||i |||m |||e ||${NC}"
    echo " ${GREEN}||__|||__|||__|||__|||__|||__|||__|||__||${NC}"
    echo " ${GREEN}|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|${NC}"
    echo "${RED}"

cat << "EOF"
 ____     ______  ____     __  __   __  __  ____     
/\  _`\  /\  _  \/\  _`\  /\ \/\ \ /\ \/\ \/\  _`\   
\ \ \L\ \\ \ \L\ \ \ \/\_\\ \ \/'/'\ \ \ \ \ \ \L\ \ 
 \ \  _ <'\ \  __ \ \ \/_/_\ \ , <  \ \ \ \ \ \ ,__/ 
  \ \ \L\ \\ \ \/\ \ \ \L\ \\ \ \\`\ \ \ \_\ \ \ \/  
   \ \____/ \ \_\ \_\ \____/ \ \_\ \_\\ \_____\ \_\  
    \/___/   \/_/\/_/\/___/   \/_/\/_/ \/_____/\/_/  

EOF
    echo "${NC}"
}

function _echo() {
    local ECHO
    declare -a ECHO 
    if [ "$#" -eq 1 ]; then
        ECHO=("$@")
    else
        local TYPE=$1
        shift
        if [ "$#" -gt 1 ]; then
            TYPE="${TYPE} [$1]"
            shift
        fi
        ECHO=("${TYPE}" "$@")
    fi

    if [ "${QUIET}" = true ]; then
        echo "${ECHO[@]}" >> "${LOG_FILE}"
    else
        echo "${ECHO[@]}" 2>&1 | tee -a "${LOG_FILE}"
    fi
}

function print() {
    _echo "$@"
}

function info() {
    _echo "${GREEN}[INFO] ${NC}" "$@"
}

function error() {
    _echo "${RED}[ERROR]${NC}" "$@"
}
