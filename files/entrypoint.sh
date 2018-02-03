#!/usr/bin/env bash

umask 000

if [[ "${DOCROOT}" != "" ]]; then
    sed -i "s#<<DOCROOT>>#${DOCROOT}/#" /etc/nginx/sites-enabled/vhost.conf
fi

if [[ ! -z "${AUTOSTART_XVFB}" ]]; then
    sed -i "s#<<AUTOSTART_XVFB>>#true#" /etc/supervisord.conf
    sed -i "s#--disable-gpu --headless##" /etc/supervisord.conf
else
    sed -i "s#<<AUTOSTART_XVFB>>#false#" /etc/supervisord.conf
fi

if [[ ! -z "${CHROME_BUILD}" ]]; then
    sed -i "s#google-chrome-stable#${CHROME_BUILD}#" /etc/supervisord.conf
fi

/usr/bin/supervisord -n -c /etc/supervisord.conf > /dev/null 2>&1 &

if [[ $# -eq 1 && $1 == "bash" ]]; then
    $@
else
    exec "$@"
fi
