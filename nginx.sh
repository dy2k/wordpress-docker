#!/bin/sh
trap "exit" SIGTERM
CERT_HOME=/etc/letsencrypt/live/$DOMAIN
RELOAD=/usr/share/nginx/reload.sh
while :; do
  if [ -f $CERT_HOME/fullchain.pem ] && [ -f $CERT_HOME/privkey.pem ]; then
    break
  fi
  sleep 10
done
if [ ! -f $RELOAD ]; then
  printf "Replacing domain name in nginx configuration file... "
  cp /usr/share/nginx/default.conf /etc/nginx/conf.d/default.conf
  sed -i "s|\$DOMAIN|${DOMAIN}|" /etc/nginx/conf.d/default.conf
  echo Done
  printf "Generating certificate reload program... "
  echo nginx -s reload > $RELOAD
  chmod a+x $RELOAD
  echo Done
fi
nohup inotifyd $RELOAD $CERT_HOME/fullchain.pem:c > /var/log/nginx/access.log &
nginx -g "daemon off;"
