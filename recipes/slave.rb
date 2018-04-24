homedir = node['hopsworks']['user'].eql?("root") ? "/root" : "/home/#{node['hopsworks']['user']}"

# Add the master host's public key, so that it can start/stop the glassworks instance on this node using passwordless ssh.
kagent_keys "#{homedir}" do
  cb_user "#{node['hopsworks']['user']}"
  cb_group "#{node['hopsworks']['group']}"
  cb_name "hopsworks"
  cb_recipe "master"  
  action :get_publickey
end  

