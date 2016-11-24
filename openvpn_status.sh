#!/bin/bash
#
# check openvpn
#

# config
DEVICE="tun0"
STATS_FILE="/proc/net/dev"
INTERFACES="$(cat ${STATS_FILE})"
OPENVPN_INIT="/etc/init.d/openvpn"
OPENVPN_STATUS="$(${OPENVPN_INIT} status)"
OPENVPN_PID="$(pgrep -f /usr/sbin/openvpn)"
ERRORS="0"

#script
if [ -z "${INTERFACES}" ]; then
    echo "unknown error - no interface stats ${INTERFACES}"
    exit 2
fi

if [ -z "$(echo ${INTERFACES} | grep ${DEVICE})" ];then
    echo "no such device ${DEVICE}"
    let ERRORS=ERRORS+1
else
    echo "found device ${DEVICE}"
fi

if [ -z "$(echo ${OPENVPN_STATUS} | egrep -i '(running|active)')" ]; then
    echo "OpenVPN not running"
    echo "${OPENVPN_STATUS}"
    let ERRORS=ERRORS+1
else
    echo "${OPENVPN_STATUS}"
fi

if [ -z "${OPENVPN_PID}" ]; then
    echo "Can't find OpenVPN PID"
    let ERRORS=ERRORS+1
else
    echo "OpenVPN PID = ${OPENVPN_PID}"
fi

if [ ${ERRORS} != "0" ]; then
    echo "OpenVPN Error. Restarting VPN Client."
    ${OPENVPN_INIT} restart
    exit 1
else
    echo "OpenVPN OK"
    exit 0
fi
