
  bash 'remove-glassfish' do
    user "root"
    ignore_failure true
    code <<-EOF
        service glassfish-domain1 stop
        systemctl stop glassfish-domain1
        pid=$(sudo lsof -t -i :4848 -s TCP:LISTEN)
        if [ $pid != "" ] ; then
           kill $pid
        fi
        rm -rf #{node['glassfish']['domains_dir']}
        rm -rf #{node['glassfish']['install_dir']}/glassfish
        rm -f /etc/init.d/glassfish-domain1
        rm -f /usr/lib/systemd/system/glassfish-domain1.service
        rm -f /lib/systemd/system/glassfish-domain1.service
        rm -f /etc/systemd/system/glassfish-domain1.service
    EOF
  end

directory "#{node['glassfish']['install_dir']}/glassfish" do
  recursive true
  action :delete
  ignore_failure true
end

directory "#{node['glassfish']['domains_dir']}" do
  recursive true
  action :delete
  ignore_failure true
end



