hop-dashboard-chef
==================

Chef cookbook to install Hop Dashboard


Vagrant Installation
==================
Install the omnibus plugin, if needed:
````
vagrant plugin install vagrant-omnibus
````

Start vagrant:
````
cd <base-dir for hopsworks-chef>
berks vendor cookbooks
vagrant up
````
Access hopsworks from your browser, with the username and password below:

````
http://localhost:9090/hopsworks
````
(`user: admin@kth.se`)
(`password: admin`)



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
