#!/usr/bin/env bash

echo
echo
echo
echo "------------------------------------"
echo "Installation of gitweb behind NGINX,"
echo "using spawn-cgi and fcgiwrap"
echo "------------------------------------"
echo
echo
echo
echo
echo
echo -n "Do you want to install NGINX? [y/n]:"
read

if [ $REPLY = y ] ; then
	echo "Installing NGINX ..."
	apt-get -q -y install nginx
fi

echo
echo "Installing gitweb ..."
apt-get -q -y install gitweb
echo
echo -n "Create directory for your repos? [y/n]:"
read

if [ $REPLY = y ] ; then
	echo -n "Path for the repo folder? [/var/repos]:"
	read
	echo $REPLY
	mkdir -p $REPLY
	chmod 777 $REPLY
fi

echo
echo "Installing spawn-fcgi"
apt-get -q -y install spawn-fcgi
echo
echo "Installing fcgiwrap dependencies"
apt-get -q -y install libfcgi-dev
echo
echo "Installing fcgiwrap"
git clone git://github.com/gnosek/fcgiwrap.git /tmp
autoreconf -i /tmp/fcgiwrap
/tmp/fcgiwrap/configure
make /tmp/fcgiwrap/Makefile
make /tmp/fcgiwrap/Makefile install

echo
echo
echo
echo "Installation OK!"
echo
echo "Next steps:"
echo "-----------"
echo "\tspawn an instance of spawn-fcgi (change settings if you need):"
echo "\tspawn-fcgi -f /usr/local/sbin/fcgiwrap -a 127.0.0.1 -p 9001"
echo
echo "\tupdate the nginx server configuration:"
echo ""
echo "\tserver {"
echo "\t    listen 80;"
echo "\t    server_name mc.raynes.me;"
echo "\t    location / {"
echo "\t        root /usr/share/gitweb;"
echo "\t        if (!-f \$request_filename) {"
echo "\t            fastcgi_pass   127.0.0.1:9001;"
echo "\t        }"
echo "\t        fastcgi_index  index.cgi;"
echo "\t        fastcgi_param  SCRIPT_FILENAME  /usr/share/gitweb/gitweb.cgi;"
echo "\t        include        fastcgi_params;"
echo "\t    }"
echo "\t}"
exit 0;

