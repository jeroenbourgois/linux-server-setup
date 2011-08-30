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

"
}


# check for root
check_root

# ACTUAL INSTALL

nginx=false
spawnfcgi=true
fcgiwrap=true

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
  curdir=${PWD}

  if [ -d "/tmp/fcgiwrap" ] ; then
    cd /tmp/fcgiwrap
    git pull
    cd $curdir
  else
    git clone git://github.com/gnosek/fcgiwrap.git /tmp/fcgiwrap
    cd /tmp/fcgiwrap
    autoreconf -i
    ./configure
    make 
    make install
    cd $curdir
  fi
fi

finish
exit 0
