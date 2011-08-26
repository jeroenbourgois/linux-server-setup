#!/usr/bin/env bash

# check for root
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo "NOT RUNNING AS ROOT! ABORT."
  exit
fi


printf "

------------------------------------
Installation of gitweb behind NGINX,
using spawn-cgi and fcgiwrap
------------------------------------

"

echo -n "Do you want to install NGINX? [y/n]:"
read

if [ $REPLY = y ] ; then
	echo "Installing NGINX ..."
	apt-get -qq -y install nginx
fi

echo
echo "Installing gitweb ..."
apt-get -qq -y install gitweb
echo
echo -n "Create directory for your repos? [y/n]:"
read

if [ $REPLY = y ] ; then
	echo -n "Path for the repo folder? [/var/repos]:"
	read
  if [[ -z "$REPLY" ]]; then
  	DIR="/var/repos"
  else
  	DIR=$REPLY
  fi
	mkdir -p $DIR
	chmod 777 $DIR
fi

echo
echo "Installing spawn-fcgi"
apt-get -qq -y install spawn-fcgi
echo
echo "Installing fcgiwrap dependencies"
apt-get -qq -y install libfcgi-dev
echo
echo "Installing fcgiwrap"
git clone git://github.com/gnosek/fcgiwrap.git /tmp/fcgiwrap
autoreconf -i /tmp/fcgiwrap
/tmp/fcgiwrap/configure
make -C /tmp/fcgiwrap/
make -C /tmp/fcgiwrap/ install

printf "
Installation OK!

Next steps:
-----------
spawn an instance of spawn-fcgi (change settings if you need):
  spawn-fcgi -f /usr/local/sbin/fcgiwrap -a 127.0.0.1 -p 9001

update the nginx server configuration:

  server {
      listen 80;
      server_name mc.raynes.me;
      location / {
          root /usr/share/gitweb;
          if (!-f \$request_filename) {
              fastcgi_pass   127.0.0.1:9001;
          }
          fastcgi_index  index.cgi;
          fastcgi_param  SCRIPT_FILENAME  /usr/share/gitweb/gitweb.cgi;
          include        fastcgi_params;
      }
  }
"

exit 0;

