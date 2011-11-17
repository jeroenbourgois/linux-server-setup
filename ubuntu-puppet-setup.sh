#!/bin/bash

##################################
# Small script to get the
# server ready for puppet
##################################

# COLORS
COL_BLUE="\x1b[34;01m"
COL_RESET="\x1b[39;49;00m"
COL_RED="\x1b[31;01m"

_log() {
  _print "$1 ******************************************"
}

_print() {
  printf $COL_BLUE"\n$1\n"$COL_RESET >> /root/manifest
}

_error() {
  _print $COL_RED"Error:\n$1\n" >> /root/manifest
}

# check for root
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  _error "NOT RUNNING AS ROOT! ABORTING."
  exit 0
fi

_log ""
_log "Preparing machine for puppet, started on `date`"
_log ""

_log "Install dependencies"
apt-get install libopenssl-ruby rdoc libopenssl-ruby1.8 libreadline-ruby1.8 libruby1.8 rdoc1.8 ruby1.8 git

_log "Get puppet and facter"
_log "Files coming from http://puppetlabs.com/misc/download-options/"
_log "Last version here is from 17/11/2011"
cd /tmp
wget http://puppetlabs.com/downloads/facter/facter-1.6.3.tar.gz
wget http://puppetlabs.com/downloads/puppet/puppet-2.7.6.tar.gz
tar xvzf facter-1.6.3.tar.gz
cd facter-1.6.3
ruby install.rb
cd ..
tar xvzf puppet-2.7.6.tar.gz
cd puppet-2.7.6
ruby install.rb
puppetd --version > /root/manifest

_log "Import puppet cookbook"
_log "Delete puppet dir if it exists, possible due to install"
if [ -d "/etc/puppet" ] ; then
  _log "Removed existing default puppet dir"
  rm -rf /etc/puppet
fi

cd /etc
git clone git://github.com/jeroenbourgois/jack-puppet.git puppet

_log "Puppet is ready for the master"
