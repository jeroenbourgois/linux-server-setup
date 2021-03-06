#!/bin/bash

##################################
# Small script to install gitweb #
##################################

# HELPER FUNCTIONS

# check for root
check_root() {
  if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo
    echo "#####################################"
    echo "Error: NOT RUNNING AS ROOT! ABORTING."
    echo "#####################################"
    echo
    usage
    exit 0
  fi
}

# help info
usage() {
  printf "
------------------------------------
Installation of gitweb behind NGINX,
using spawn-cgi and fcgiwrap
------------------------------------

You need to run the script as root, there is no way all of this will install as normal user :P

Options:
 
  -h  : show this message
  -n  : install the default nginx package
  -f  : omits the install spawnfcgi to spawn fcgi processes (if you have another spawner, it's fine)
  -s  : omits the installation of fcgiwrap (needed for nginx)
  -t  : omits the github theme for gitweb, using the default theme (github theme by kogakure, http://github.com/kogakure/gitweb-theme)
  "
  exit 0
}

finish() {
  printf "
******************************

Installation OK!

Next steps:
-----------
spawn an instance of spawn-fcgi (or your own, change settings if you need):
  spawn-fcgi -f /usr/local/sbin/fcgiwrap -a 127.0.0.1 -p 9001

update the nginx server configuration:

  server {
      listen 80;
      server_name yourdomain.com;

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

update the gitweb.conf file (located by default in /etc/gitweb.conf):

The extra theme has copied the old css file for safety to .old in the /usr/share/gitweb/static folder :)
"
}


# check for root
check_root

# ACTUAL INSTALL

nginx=false
spawnfcgi=true
fcgiwrap=true
themed=true

while getopts "hnfs" opt; do 
  case $opt in
    h)
      usage
      ;;
    n)
      nginx=true
      ;;
    f)
      spawnfcgi=false
      ;;
    s)
      fcgiwrap=false
      ;;
    t)
      themed=false
      ;;
  esac 
done

echo "Starting installation:"
if $nginx ; then
  echo "Installing NGINX ..."
  apt-get -qq -y install nginx
fi

echo "Installing gitweb ..."
apt-get -qq -y install gitweb

if $spawnfcgi ; then
  echo "Installing spawn-fcgi"
  apt-get -qq -y install spawn-fcgi
fi

if $fcgiwrap ; then
  echo "Installing fcgiwrap dependencies"
  apt-get -qq -y install libfcgi-dev

  echo "Installing fcgiwrap"

  if [ -d "/tmp/fcgiwrap" ] ; then
  	echo "      > You seem to have the fcgiwrap repo, recompile yourself if needed!"
  else
    git clone git://github.com/gnosek/fcgiwrap.git /tmp/fcgiwrap
    curdir=${PWD}
    cd /tmp/fcgiwrap
    autoreconf -i
    ./configure
    make 
    make install
    cd $curdir
  fi
fi

if $themed ; then
  echo "Installing github theme for gitweb by kogakure"
  curdir=${PWD}

  if [ -d "/tmp/gitweb-theme" ] ; then
    cd /tmp/gitweb-theme
    git pull
    cd $curdir
  else
    git clone https://github.com/kogakure/gitweb-theme.git /tmp/gitweb-theme
  fi

  mv /usr/share/gitweb/static/gitweb.css /usr/share/gitweb/static/gitweb.css.old
  mv /usr/share/gitweb/static/gitweb.js /usr/share/gitweb/static/gitweb.js.old
  cp /tmp/gitweb-theme/gitweb.css /usr/share/gitweb/static/gitweb.css
  cp /tmp/gitweb-theme/gitweb.js /usr/share/gitweb/static/gitweb.js
fi

finish
exit 0
