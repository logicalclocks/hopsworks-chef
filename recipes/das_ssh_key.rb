glassfish_user_home = conda_helpers.get_user_home(node['glassfish']['user'])

nodedir=node['glassfish']['nodes_dir']

# Add the DAS node's public key, so that it can start/stop the work instances on this node using passwordless ssh.
kagent_keys "#{glassfish_user_home}" do
  cb_user "#{node['glassfish']['user']}"
  cb_group "#{node['glassfish']['group']}"
  cb_name "hopsworks"
  cb_recipe "default"  
  action :get_publickey
end  

directory "#{nodedir}" do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "750"
  action :create
  not_if "test -d #{nodedir}"
end