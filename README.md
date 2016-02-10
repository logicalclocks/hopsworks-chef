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


## On-Premise RedHat/Centos/Fedora Installations

By default, Redhat/Centos/Fedora disable "ssh hostname sudo <cmd>", because it will show the password in clear. 
This prevents Karamel from executing Chef recipes on bare-metal Centos/Redhat hosts. To overcome this, you can
force the use of a pseudeo-terminal, by commenting out the following line in **/etc/sudoers**:

# Comment out this line below, in /etc/sudoers
#Defaults    requiretty

This has to be done for all hosts in the cluster on which Karamel will be executed.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
