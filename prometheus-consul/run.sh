#!/bin/sh

set -e
set -u

# for debugging of this script
DEBUG=${DEBUG:-"0"}
if [ "$DEBUG" -eq "1" ]; then
    set -x
fi

readonly PROMETHEUS_CONFIG_DIR="/etc/prometheus"
ERROR=0

WEB_HOSTNAME=${WEB_HOSTNAME:-""}
if [ ! -z "${WEB_HOSTNAME}" ]; then
  ARG_EXTERNAL_URL="--web.external-url=http://${WEB_HOSTNAME}:9090"
else
  ARG_EXTERNAL_URL=""
fi

RETENTION_PERIOD=${RETENTION_PERIOD:-""}
if [ ! -z "${RETENTION_PERIOD}" ]; then
  ARG_RETENTION_PERIOD="--storage.tsdb.retention=${RETENTION_PERIOD}"
else
  ARG_RETENTION_PERIOD=""
fi

function check_var() {
  set +u
  if [ -z "$(eval echo \$${1})" ]; then
    echo "Variable '${1}' needs to be set"
    ERROR=1
  fi
  set -u
}

for var in "CONSUL_SERVER CONSUL_TOKEN KEY_PATH ALERT_KEY_PATH"; do
  check_var ${var}
done

if [ "$ERROR" -ne "0" ]; then
  exit 1
fi

sed -e "s|%CONSUL_SERVER%|${CONSUL_SERVER}|" \
    -e "s|%CONSUL_TOKEN%|${CONSUL_TOKEN}|" \
    -e "s|%KEY_PATH%|${KEY_PATH}|" \
    -i "${PROMETHEUS_CONFIG_DIR}/prometheus.yml.ctmpl"

sed -e "s|%ALERT_KEY_PATH%|${ALERT_KEY_PATH}|" \
    -i "$PROMETHEUS_CONFIG_DIR/alert.rules.ctmpl"

exec consul-template -consul-addr="${CONSUL_SERVER}" -consul-token="${CONSUL_TOKEN}" \
  -template="${PROMETHEUS_CONFIG_DIR}/alert.rules.ctmpl:${PROMETHEUS_CONFIG_DIR}/alert.rules:/reload-prometheus.sh" \
  -template="${PROMETHEUS_CONFIG_DIR}/prometheus.yml.ctmpl:${PROMETHEUS_CONFIG_DIR}/prometheus.yml:/reload-prometheus.sh" &

readonly TIMEOUT_SECS=15
ELAPSED_SECS=0
while [ ! -f /etc/prometheus/prometheus.yml ]; do
  if [ "${ELAPSED_SECS}" -ge "${TIMEOUT_SECS}" ]; then
      echo "prometheus configuration not found, please check your consultemplate settings" >&2
      exit 1
  fi
  sleep 1
  ELAPSED_SECS=$((ELAPSED_SECS+1))
done

exec prometheus ${ARG_EXTERNAL_URL} --config.file ${PROMETHEUS_CONFIG_DIR}/prometheus.yml ${ARG_RETENTION_PERIOD}
