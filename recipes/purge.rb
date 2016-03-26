
  bash 'remove-glassfish' do
    user "root"
    ignore_failure true
    code <<-EOF
        service glassfish-domain1 stop
        systemctl stop glassfish-domain1 
        pid=$(sudo netstat -lptn | grep 4848 | awk '{print $7}')
        pid=echo "${pid//[!0-9]/}"
        if [ $pid != "" ] ; then
           kill $pid
        fi
        rm -rf /usr/local/glassfish
        rm -rf /srv/glassfish
        rm -f /etc/init.d/glassfish-domain1
        rm -f /usr/lib/systemd/system/glassfish-domain1.service
        rm -f /lib/systemd/system/glassfish-domain1.service
        rm -f /etc/systemd/system/glassfish-domain1.service
        /var/lib/mysql-cluster/ndb/scripts/mysql-client.sh -e "drop database hopsworks"
    EOF
  end

