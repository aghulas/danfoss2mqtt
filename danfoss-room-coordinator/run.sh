#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -euo pipefail

# Auto-discover Home Assistant's Mosquitto broker when mqtt_host is left empty.
MQTT_HOST="$(bashio::config 'mqtt_host')"
if [ -z "${MQTT_HOST}" ] && bashio::services.available "mqtt"; then
    DANFOSS_MQTT_HOST="$(bashio::services mqtt "host")"
    DANFOSS_MQTT_PORT="$(bashio::services mqtt "port")"
    DANFOSS_MQTT_USERNAME="$(bashio::services mqtt "username")"
    DANFOSS_MQTT_PASSWORD="$(bashio::services mqtt "password")"
    export DANFOSS_MQTT_HOST DANFOSS_MQTT_PORT DANFOSS_MQTT_USERNAME DANFOSS_MQTT_PASSWORD
    bashio::log.info "Using Home Assistant Mosquitto service at ${DANFOSS_MQTT_HOST}:${DANFOSS_MQTT_PORT}"
fi

export DANFOSS_OPTIONS_FILE="/data/options.json"
bashio::log.info "Starting danfoss-room-coordinator..."
exec danfoss-room-coordinator --options "${DANFOSS_OPTIONS_FILE}"
