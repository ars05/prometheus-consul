#!/bin/sh

set -e
set -u

# for debugging of this script
DEBUG=${DEBUG:-"0"}
if [ "$DEBUG" -eq "1" ]; then
    set -x
fi

readonly TIMEOUT_SECONDS=15
readonly PROMETHEUS_CONFIG_DIR="/etc/prometheus"
ERROR=0

function check_var() {
  set +u
  if [ -z "$(eval echo \$${1})" ]; then
    echo "Variable '${1}' needs to be set"
    ERROR=1
  fi
  set -u
}

for var in "CONSUL_SERVER CONSUL_TOKEN ALERT_KEY_PATH"; do
  check_var ${var}
done

if [ "$ERROR" -ne "0" ]; then
  exit 1
fi

sed -e "s|%ALERT_KEY_PATH%|${ALERT_KEY_PATH}|" \
    -i "$PROMETHEUS_CONFIG_DIR/alert.rules.ctmpl"

set +e
timeout -t ${TIMEOUT_SECONDS} consul-template -consul-addr="${CONSUL_SERVER}" -consul-token="${CONSUL_TOKEN}" \
  -template="${PROMETHEUS_CONFIG_DIR}/alert.rules.ctmpl:${PROMETHEUS_CONFIG_DIR}/alert.rules:/reload-prometheus.sh" -once
readonly CONSUL_TEMPLATE_RETURN_CODE=$?
set -e

if [ "$CONSUL_TEMPLATE_RETURN_CODE" -ne "0" ]; then
    echo "error: unexpected return code from consul-template: ${CONSUL_TEMPLATE_RETURN_CODE}"
    exit $CONSUL_TEMPLATE_RETURN_CODE
fi

set +e
readonly PROMTOOL_OUTPUT=$(promtool update rules ${PROMETHEUS_CONFIG_DIR}/alert.rules 2>&1)
readonly PROMTOOL_RETURN_CODE=$?
set -e
if [ "$PROMTOOL_RETURN_CODE" -ne "0" ]; then
    echo "$PROMTOOL_RETURN_CODE" 1>&2
    exit $PROMTOOL_RETURN_CODE
fi
cat ${PROMETHEUS_CONFIG_DIR}/alert.rules.yml
