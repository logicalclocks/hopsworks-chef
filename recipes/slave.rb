glassfish_user_home = conda_helpers.get_user_home(node['glassfish']['user'])

# Add the master host's public key, so that it can start/stop the glassworks instance on this node using passwordless ssh.
kagent_keys "#{glassfish_user_home}" do
  cb_user "#{node['glassfish']['user']}"
  cb_group "#{node['glassfish']['group']}"
  cb_name "hopsworks"
  cb_recipe "default"  
  action :get_publickey
end  

# Register Glassfish with Consul
template "#{node['glassfish']['domains_dir']}/#{node['hopsworks']['domain_name']}/bin/glassfish-health.sh" do
  source "consul/glassfish-health.sh.erb"
  owner node['hopsworks']['user']
  group node['hops']['group']
  mode 0750
end

consul_service "Registering Glassfish worker with Consul" do
  service_definition "consul/glassfish-worker-consul.hcl.erb"
  reload_consul false
  action :register
end