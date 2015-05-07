notifying_action :create_db do
  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"
  bash 'grants_kthfs' do
    user "root"
    code <<-EOF
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS kthfs\"
    EOF
  end
end

notifying_action :populate_db do

  Chef::Log.info("Tables.sql is here: #{new_resource.tables_path}")
  Chef::Log.info("Rows.sql is here: #{new_resource.tables_path}")
  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"
  bash 'populate_kthfs_tables' do
    user "root"
    code <<-EOF
      #{exec} kthfs -e \"source #{new_resource.tables_path}\"
      #{exec} kthfs -e \"source #{new_resource.rows_path}\"
    EOF
    not_if "#{exec} kthfs < \"show tables;\" | grep Hosts"
  end
end

notifying_action :sshkeys do
  # Set attribute for dashboard's public_key to the ssh public key
  key=IO.readlines("#{node['glassfish']['base_dir']}/.ssh/id_rsa.pub").first
  node.normal[:hopsworks][:public_key]=key.gsub("\n","")
end
