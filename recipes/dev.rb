  bash 'dev-setup' do
    user "root"
    code <<-EOF
       apt-get install git -y 
       apt-get install nodejs -y
       apt-get install npm -y
#       npm cache clean && npm uninstall -g bower && npm install -g bower
       npm install -g bower
       ln -s /usr/bin/nodejs /usr/bin/node

       perl -pi -e "s/--debug false/--debug true/g" /etc/init.d/glassfish-domain1
       service glassfish-domain1 stop
       sleep 1
       service glassfish-domain1 start
    EOF
  end




