#!/bin/bash

set -e

SCRIPTNAME=`basename $0`
SCRIPTDIR=`dirname $0`
BASEDIR=`dirname $SCRIPTDIR`


if [ $# -ne 1 ] ; then
    echo "Usage: $0 BRANCH"
    exit 2
fi

BRANCH=".${1}"

# Read from the file: ./$BRANCH
# the list of affected cookbooks
# For each cookbook, increment its version and hopsworks-chef, and publish a new version of hopsworks

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
    pushd .
    cd ../${line}
#    git commit -am "finished ${1}"
    git push
    popd
done < "$BRANCH"
