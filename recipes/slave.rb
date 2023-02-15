glassfish_user_home = conda_helpers.get_user_home(node['glassfish']['user'])

# Add the master host's public key, so that it can start/stop the glassworks instance on this node using passwordless ssh.
kagent_keys "#{glassfish_user_home}" do
  cb_user "#{node['glassfish']['user']}"
  cb_group "#{node['glassfish']['group']}"
  cb_name "hopsworks"
  cb_recipe "default"  
  action :get_publickey
end  

consul_service "Registering Glassfish worker with Consul" do
  service_definition "consul/glassfish-worker-consul.hcl.erb"
  reload_consul false
  action :register
end

#need to grant access to airflow and feature store users
bash 'create_hopsworks_db' do
  user "root"
  code <<-EOF
      set -e
      #{exec} -e \"GRANT ALL PRIVILEGES ON #{node['hopsworks']['db']}.* TO \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\';\"
      #{exec} -e \"GRANT SELECT ON #{node['hops']['db']}.* TO \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\';\"
      # Hopsworks needs to the quotas tables
      #{exec} -e \"GRANT ALL PRIVILEGES ON #{node['hops']['db']}.yarn_projects_quota TO \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\';\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON #{node['hops']['db']}.hdfs_directory_with_quota_feature TO \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\';\"
      #{exec} -e \"GRANT SELECT ON metastore.* TO \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\';\"      
    EOF
end