use_inline_resources

notifying_action :create_tables do
  Chef::Log.info("Tables.sql is here: #{new_resource.tables_path}")
  db="hopsworks"
  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"

  bash 'create_hopsworks_tables' do
    user "root"
    code <<-EOF
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS hopsworks\"
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS glassfish_timers\"
      #{exec} #{db} -e \"source #{new_resource.tables_path}\"
    EOF
    not_if "#{exec} #{db} < \"show tables;\" | grep users"
  end

end

notifying_action :insert_rows do
  Chef::Log.info("Rows.sql is here: #{new_resource.rows_path}")
  db="hopsworks"
  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"

  bash 'insert_hopsworks_rows' do
    user "root"
    code <<-EOF
      #{exec} #{db} -e \"source #{new_resource.rows_path}\"
      #{exec} glassfish_timers -e \"source /usr/local/glassfish/versions/current/glssfish/lib/install/databases/ejbtimer_mysql.sql\"
    EOF
  end
end

notifying_action :sshkeys do
  # Set attribute for dashboard's public_key to the ssh public key
  key=IO.readlines("#{node['glassfish']['base_dir']}/.ssh/id_rsa.pub").first
  node.normal[:hopsworks][:public_key]=key.gsub("\n","")
end
