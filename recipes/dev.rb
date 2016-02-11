  bash 'dev-setup' do
    user "root"
    code <<-EOF
       apt-get install git -y
       apt-get install node -y
       apt-get install npm -y
#       npm cache clean && npm uninstall -g bower && npm install -g bower
       npm install -g bower

       perl -pi -e "s/--debug false/--debug true/g" /etc/init.d/glassfish-domain1
       service glassfish-domain1 stop
       sleep 1
       service glassfish-domain1 start
    EOF
  end




