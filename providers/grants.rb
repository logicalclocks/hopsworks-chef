action :reload_systemd do

if node['services']['enabled'] == "true"
  bash 'enable_systemd' do
    user "root"
    ignore_failure true
    code <<-EOF
          systemctl daemon-reload
          systemctl reset-failed
          systemctl enable glassfish-domain1
    EOF
  end
end

  bash 'reload_systemd' do
    user "root"
    retries 1
    code <<-EOF
          systemctl daemon-reload
          service glassfish-domain1 restart
    EOF
  end

end

action :create_timers do
  exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

  bash 'create_timers_tables' do
    user "root"
    code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS glassfish_timers CHARACTER SET latin1\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON glassfish_timers.* TO \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\';\"
      #{exec} glassfish_timers < #{new_resource.tables_path}
    EOF
    not_if "#{exec} -e 'show databases' | grep glassfish_timers"
  end


end

action :sshkeys do
  # Set attribute for dashboard's public_key to the ssh public key
  key=IO.readlines("#{node['glassfish']['base_dir']}/.ssh/id_rsa.pub").first
  node.normal['hopsworks']['public_key']=key.gsub("\n","")
end

