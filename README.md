HopsWorks
==================

Chef cookbook to install HopsWorks, Hadoop for Humans.


Vagrant Installation
==================

Requirements: Vagrant, Virtualbox, Min 9 GB of main memory

Install the omnibus plugin, if needed:
````
vagrant plugin install vagrant-omnibus
````


Clone this repo, then run:
````
cd hopsworks-chef
# remove any old berkshelf cookbooks/cache
rm -rf cookbooks Berksfile.lock
berks vendor cookbooks
vagrant up
````

After hopsworks has installed, access hopsworks from your browser, with the username and password below:
````
http://localhost:8080/hopsworks
````
# Default credentials:
````
user: admin@kth.se
password: admin
````


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
