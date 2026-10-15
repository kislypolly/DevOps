#!/usr/bin/env bash

# Проверяем, передано ли имя сервиса
if [ -z "$1" ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

SERVICE="$1"

# Проверяем состояние сервиса
STATUS=$(systemctl is-active "$SERVICE")

echo "Service: $SERVICE"
echo "Status: $STATUS"

# Если сервис не работает, показываем журнал
if [ "$STATUS" != "active" ]; then
    echo "Last 10 journal lines:"
    journalctl -u "$SERVICE" -n 10 --no-pager
fi

# Считаем ошибки в syslog за последний час
echo "Errors in syslog during the last hour:"

if [ -r /var/log/syslog ]; then
    ERRORS=$(awk -v since="$(date -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')" '
        {
            timestamp = $1
            sub(/\.[0-9]+/, "", timestamp)
            sub(/[+-][0-9][0-9]:[0-9][0-9]$/, "", timestamp)

            if (timestamp >= since) {
                print
            }
        }
    ' /var/log/syslog | grep -Eic 'error|failed|failure')

    echo "$ERRORS"
else
    echo "Cannot read /var/log/syslog"
fi
