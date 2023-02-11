homedir = node['hopsworks']['user'].eql?("root") ? "/root" : conda_helpers.get_user_home(node['glassfish']['user'])

# Add the master host's public key, so that it can start/stop the glassworks instance on this node using passwordless ssh.
kagent_keys "#{homedir}" do
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