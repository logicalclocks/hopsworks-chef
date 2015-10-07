HopsWorks
==================

Chef cookbook to install HopsWorks, Hadoop for Humans.


Vagrant Installation
==================

Minimum Requirements: 9 GB of main memory

````
cd hopsworks-chef
berks vendor cookbooks
vagrant up
````

After hopsworks has installed, you can access hopsworks from a web browser at:
````
http://localhost:8080/hopsworks

# Enter the following account credentials:
user: admin@kth.se
password: admin
````



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
