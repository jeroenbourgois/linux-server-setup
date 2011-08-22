#!/bin/bash

##########################################
# Debian automated install post setup script
##########################################
# English

# Install Debian Server basics
# hostname: susan
##########################################

echo "Post install started on `date`" > /root/manifest

# START
echo "* Updating Apt..." >> /root/manifest
apt-get update
echo "* Updating system..." >> /root/manifest
apt-get upgrade

# BASE
echo "* Installing essential packages..." >> /root/manifest
apt-get -y install build-essential bison openssl libreadline5 libreadline-dev curl git-core zlib1g sudo
apt-get -y install zlib1g-dev libssl-dev libsqlite3-0 libsqlite3-dev sqlite3 libcurl4-openssl-dev
apt-get -y install libreadline-dev libxml2-dev subversion autoconf

# VIM
echo "* Installing VIM..." >> /root/manifest
apt-get -y install vim

# Hostname
# echo "susan" > /etc/hostname
# hostname -F /etc/hostname

#
# I need: ruby + rubygems + rvm + capistrano

# Base ruby
echo "* Installing Ruby..." >> /root/manifest
apt-get install ruby libzlib-ruby rdoc irb libyaml-ruby

# RVM
echo "* Installing RVM..." >> /root/manifest
bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

# Thin webserver
#gem install thin

# Ginatra
#gem install ginatra
#apt-get -y install python-pygments # dependency of ginatra

# NGINX
# apt-get --force-yes install nginx

