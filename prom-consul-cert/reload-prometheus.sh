#!/bin/sh
PROM_PID=$(pgrep prometheus)
if [ -n "${PROM_PID}" ]; then
    echo "Reloading prometheus config"
    kill -HUP ${PROM_PID}
fi
