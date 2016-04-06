#!/bin/bash

cat hopsworks.json | sed -e "s/XXX/$USER/g" > hopsworks.json.new
mv hopsworks.json.new hopsworks.json
echo "Removing old vendored cookbooks"
rm -rf /tmp/cookbooks > /dev/null 2>&1
rm -f Berksfile.lock nohup.out > /dev/null 2>&1
echo "Vendoring cookbooks  to '/tmp/cookbooks' using 'berks vendor cookbooks'"
rm Berksfile.lock
berks vendor /tmp/cookbooks

echo "Running: 'chef-solo -c solo.rb -j hopsworks.json'"
sudo chef-solo -c solo.rb -j hopsworks.json
