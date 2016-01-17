
  bash 'remove-glassfish' do
    user "root"
    code <<-EOF
        service glassfish-domain1 stop
        pid=$(sudo netstat -lptn | grep 4848 | awk '{print $7}')
        pid=echo "${pid//[!0-9]/}"
        if [ $pid != "" ] ; then
           kill $pid
        fi
        rm -rf /usr/local/glassfish
        rm /etc/init.d/glassfish-domain1
        /var/lib/mysql-cluster/ndb/scripts/mysql-client.sh -e "drop database hopsworks"
    EOF
  end

