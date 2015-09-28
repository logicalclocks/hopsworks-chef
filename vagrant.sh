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
 rm -rf ${targetdir}
fi
berks vendor ${targetdir}
if [ $? -ne 0 ] ; then
  echo "Problem running berkshelf vendor command"
  exit 3
fi

vagrant up 
exit $?
