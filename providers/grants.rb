use_inline_resources


notifying_action :reload_systemd do

  bash 'reload_systemd' do
    user "root"
    code <<-EOF
          systemctl daemon-reload
          service glassfish-domain1 restart
    EOF
  end

end


notifying_action :reload_sysv do

  bash 'reload_sysv' do
    user "root"
    code <<-EOF
          service glassfish-domain1 stop
          service glassfish-domain1 start
    EOF
  end

end



notifying_action :create_timers do
  exec = "#{node.ndb.scripts_dir}/mysql-client.sh"

  bash 'create_timers_tables' do
    user "root"
    code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS glassfish_timers CHARACTER SET latin1\"
      #{exec} glassfish_timers < #{new_resource.tables_path}
    EOF
    not_if "#{exec} -e 'show databases' | grep glassfish_timers"
  end


end

notifying_action :create_tables do
  Chef::Log.info("Tables.sql is here: #{new_resource.tables_path}")
  db="hopsworks"
  exec = "#{node.ndb.scripts_dir}/mysql-client.sh"

  bash 'create_hopsworks_tables' do
    user "root"
    code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS hopsworks CHARACTER SET latin1\"
      #{exec} #{db} < #{new_resource.tables_path}
    EOF
    not_if "#{exec} -e 'show databases' | grep hopsworks"
  end

#
# There is no support for distributed views in MySQL Cluster, so each mysql server has to install
# the views
  bash 'create_hopsworks_views' do
    user "root"
    code <<-EOF
      set -e
      #{exec} #{db} < #{new_resource.views_path}
    EOF
    not_if "#{exec} hopsworks -e \"show tables like 'users_groups'\" | grep users_groups"
  end

end

notifying_action :insert_rows do
  Chef::Log.info("Rows.sql is here: #{new_resource.rows_path}")
  exec = "#{node.ndb.scripts_dir}/mysql-client.sh"
#  timerTable = "ejbtimer_mysql.sql"
#  timerTablePath = "#{Chef::Config.file_cache_path}/#{timerTable}"

 # template timerTablePath do
 #    source "#{timerTable}.erb"
 #    owner node.glassfish.user
 #    mode 0750
 #    action :create
 #  end 

  bash 'insert_hopsworks_rows' do
    user "root"
    code <<-EOF
      set -e
      #{exec} hopsworks < #{new_resource.rows_path}
      touch "#{node.glassfish.base_dir}/.hopsworks_rows.sql"
    EOF
    not_if { ::File.exists?("#{node.glassfish.base_dir}/.hopsworks_rows.sql") }
  end
end

notifying_action :sshkeys do
  # Set attribute for dashboard's public_key to the ssh public key
  key=IO.readlines("#{node.glassfish.base_dir}/.ssh/id_rsa.pub").first
  node.normal.hopsworks.public_key=key.gsub("\n","")
end

