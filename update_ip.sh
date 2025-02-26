#!/bin/sh
#
# Updates domain A zone record with WAN IP

IP_SERVICE="http://ifconfig.me"
RECORD_LIST="${RECORD_LIST:-''}"
FORCE=0

while getopts "46f" option ; do
  case $option in
    4) IP_VERSION=4 ;;
    6) IP_VERSION=6 ;;
    f) FORCE=1 ;;
  esac
done

if [[ -z ${IP_VERSION} ]]; then
    exit 1
fi

WAN_IP=$(curl -s -${IP_VERSION} ${IP_SERVICE})
res=$?
if [[ "$res" != 0 ]]; then
  echo "$(date "+[%Y-%m-%d %H:%M:%S]") [ERROR] Something went wrong. Can not get your IP from ${IP_SERVICE}. The curl command failed with: $res"
  exit 1
fi

for RECORD in ${RECORD_LIST//;/ } ; do
  if [[ "${IP_VERSION}" = 4 ]] ; then
    DNS_TYPE="A"
  else
    DNS_TYPE="AAAA"
  fi

  CURRENT_IP=$(dig ${DNS_TYPE} ${RECORD} +short | grep -v '\.$')
  if [[ "${CURRENT_IP}" = "${WAN_IP}" ]] ; then
    echo "$(date "+[%Y-%m-%d %H:%M:%S]") [INFO] Current DNS record for ${RECORD} matches WAN IP (${CURRENT_IP}). Nothing to do."
    [[ $FORCE = 0 ]] && continue
  fi

  RESULT=$(curl -s -${IP_VERSION} -X POST "https://${DYNDNS_USER}:${DYNDNS_PASSWORD}@infomaniak.com/nic/update?hostname=${RECORD}")
  if [[ "${RESULT}" =~ "good" ]] ; then
    echo "$(date "+[%Y-%m-%d %H:%M:%S]") [OK] Updated ${RECORD} to ${WAN_IP}"
  else
    echo "$(date "+[%Y-%m-%d %H:%M:%S]") [ERROR] API returned status ${RESULT}"
  fi
done
