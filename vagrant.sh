#!/bin/bash

targetdir=cookbooks
chef-solo --version
if [ $? -ne 0 ] ; then
  echo "You need to install chef-dk"
  exit 1
fi


berks --version
if [ $? -ne 0 ] ; then
  echo "You need to install chef-dk"
  exit 1
fi

if [ -d "${targetdir}" ]; then
 rm -rf cookboooks
fi
test -d ${targetdir} 
berks vendor ${targetdir}

vagrant up 
exit $?
