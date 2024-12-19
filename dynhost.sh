#!/bin/bash

# Account configuration
HOST=""
LOGIN=""
PASSWORD=""
DNSSERVER=@dns105.ovh.net

PATH_LOG=/var/log/dynhostovh.log

function log {
        CURRENT_DATETIME="[$(date -R)]"
        if [[ "$1" == "" ]]; then
                CURRENT_DATETIME=""
        fi
        echo $1
        echo "$CURRENT_DATETIME $1" >> $PATH_LOG
}

if [[ "$HOST" == "" ]] || [[ "$LOGIN" == "" ]] || [[ "$PASSWORD" == "" ]]; then
  log "No host, login or password configured! Configure in the dynhost script."
  exit
fi


log ""
log "Updating..."

# Get current IPv4 and corresponding configured
HOST_IP=$(dig $DNSSERVER +short $HOST A)
CURRENT_IP=$(curl -m 5 -4 ifconfig.co 2>/dev/null)
log "Host IP: $HOST_IP. Current IP: $CURRENT_IP"
if [ -z $CURRENT_IP ]
then
        log "Using alternative IP retrieval method"
        CURRENT_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
        log "New Current IP: $CURRENT_IP"
fi

# Update dynamic IPv4, if needed
if [ -z $CURRENT_IP ] || [ -z $HOST_IP ]
then
  log "Cannot retrieve IP's! Exiting..."
  log "Host IP: $HOST_IP"
  log "Local IP: $LOCAL_IP"
else
  if [ "$HOST_IP" != "$CURRENT_IP" ]
  then
    RES=$(curl -m 5 -L --location-trusted --user "$LOGIN:$PASSWORD" "https://www.ovh.com/nic/update?system=dyndns&hostname=$HOST&myip=$CURRENT_IP")
    log "IPv4 has changed - request to OVH DynHost: $RES"
  else
        log "Addresses are the same. Nothing to do"
  fi
fi
