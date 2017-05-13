#!/usr/bin/env bash

umask 000

if [[ "${DOCROOT}" != "" ]]; then
    sed -i "s#root /code/#root ${DOCROOT}/#" /etc/nginx/sites-enabled/mink
fi

/usr/bin/supervisord -n -c /etc/supervisord.conf > /dev/null 2>&1 &

if [[ $# -eq 1 && $1 == "bash" ]]; then
    $@
else
    exec "$@"
fi
