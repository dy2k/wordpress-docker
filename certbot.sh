#!/bin/sh
set -e
if [ -z "$DOMAIN" ]; then
  echo Domain not set. Exit with error.
  exit 1
elif [ -z "$EMAIL" ]; then
  echo Email not set. Exit with error.
  exit 2
elif [ -z "$TIMEZONE" ]; then
  echo Timezone not set. Exit with error.
  exit 3
fi
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
  if [ ! -d "/usr/share/zoneinfo" ]; then
    printf "Loading zoneinfo... "
    apk add tzdata
    echo Done
  fi
  if [ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
    echo Timezone invalid. Exit with error.
    exit 4
  elif [ $(diff /usr/share/zoneinfo/$TIMEZONE /etc/localtime | wc -l) \> 0 ]; then
    printf "Applying timezone... "
    cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    echo $TIMEZONE > /etc/timezone
    echo Done
  fi
  if [ $(pip list | grep certbot-dns-cloudflare | wc -l) \< 1 ]; then
    printf "Installing certbot-dns-cloudflare plugin... "
    pip install certbot-dns-cloudflare
    echo Done
  fi
  if [ ! -d "/var/log/letsencrypt" ]; then
    printf "Creating renewal log file... "
    mkdir /var/log/letsencrypt
    ln -sf /dev/stdout /var/log/letsencrypt/renewal.log
    echo Done
  fi
  echo "Starting to get certificate for $DOMAIN on $(date)... "
  certbot certonly --dns-cloudflare --dns-cloudflare-credentials /opt/certbot/cloudflare.ini --agree-tos --dry-run -m $EMAIL -d $DOMAIN -d www.$DOMAIN
fi
if [ ! -f "/var/lib/letsencrypt/dhparam.pem" ]; then
  openssl dhparam -out /var/lib/letsencrypt/dhparam.pem 2048
fi
trap "kill -9 $(ps -ef | grep crond | awk '{print $1}')" SIGTERM
echo "Start waiting for the next check for certificate renewal..."
/usr/sbin/crond -f
