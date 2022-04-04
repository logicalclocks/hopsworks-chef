#!/bin/bash

VERSIONS=versions.txt
if [ $# -ne 1 ] ; then
  echo "Usage: $0 version"
  echo ""
  echo "e.g., ./versions.sh 2.5"
  exit 1
fi

if [ "${PWD##*/}" != "hopsworks-chef" ] ; then
  echo "ERROR"
  echo "Run this command from the directory 'hopsworks-chef'"
  echo "PWD should be hopsworks-chef"
  exit 2
fi

git checkout $1

rm -rf /tmp/$1
berks vendor /tmp/$1

find /tmp/$1 -name "default.rb" -type f | xargs grep "\[\"version\"\]" > $VERSIONS
find /tmp/$1 -name "default.rb" -type f | xargs grep "\['version'\]" >> $VERSIONS

# make all the versions have same format as chef attr: ['version']
sed -i "s/\"version\"/'version'/g" $VERSIONS

grep -o "\['.*'\]\['version'\].*=.*[0-9]" $VERSIONS | sed -e "s/\[//g" | sed -e "s/\]//g" | sed -e "s/'//" |  sed -e "s/'//" |  sed -e "s/'/\//" |  sed -e "s/'//" |  sed -e "s/\"//" | sed -e "s/'/\//g" | sed -e "s/version'/version/" | sed -e "s/version\//version/" | sed -e "s/= \//= /" | sed -e "s/#.*//" | sed -e "s/version.*=/,/g" | sed -e "s/\/,//" | sed -e n\;d | sort > .versions.txt

mv -f .versions.txt $VERSIONS

echo "Done."

cat $VERSIONS
echo "Versions are in file: $VERSIONS"


