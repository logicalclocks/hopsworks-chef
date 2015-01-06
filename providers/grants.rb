notifying_action :grants do

    Chef::Log.info("Grants file is here: #{new_resource.grants_path}")
  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"
  bash 'grants_kthfs' do
    user "root"
    code <<-EOF
      #{exec} -e \"source #{new_resource.grants_path}\"
    EOF
  end
  not_if "#{exec} kthfs -e \"SELECT user FROM mysql.user;\"  | grep #{node[:mysql][:user]}"
end

notifying_action :kthfs do
    Chef::Log.info("Kthfs file is here: #{new_resource.kthfs_path}")
  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"
  bash 'populate_kthfs_tables' do
    user "root"
    code <<-EOF
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS kthfs\"
      #{exec} kthfs -e \"source #{new_resource.kthfs_path}\"
    EOF
    not_if "#{exec} kthfs < \"show tables;\" | grep Hosts"
  end
end

notifying_action :creds do

  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"
  bash 'populate_creds_tables' do
    user "root"
    code <<-EOF
      #{exec} kthfs -e \"source #{new_resource.creds_path}\"
    EOF
  end

end

notifying_action :graphs do

  exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"
  bash 'populate_graphs_tables' do
    user "root"
    code <<-EOF
      #{exec} kthfs -e \"source #{new_resource.graphs_path}\"
    EOF
  end

end

notifying_action :sshkeys do
  # Set attribute for dashboard's public_key to the ssh public key
  key=IO.readlines("#{node['glassfish']['base_dir']}/.ssh/id_rsa.pub").first
  node.normal[:hopshub][:public_key]=key.gsub("\n","")
end
