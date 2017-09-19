#rows_path = "#{domains_dir}/post.sql"

case node['platform']
when "rhel"
  package "openssh-clients"
end

package "openssh-server"


homedir = "/home/#{node['hopsworks']['user']}"

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  action :generate  
end  

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  cb_name "hopsworks"
  cb_recipe "master"  
  action :return_publickey
end  

domain_name="domain1"
domains_dir = node['glassfish']['domains_dir']
admin_port = 4848
username=node['hopsworks']['admin']['user']
password=node['hopsworks']['admin']['password']

#
# mod_ajp http://www.devwithimagination.com/2015/08/13/apache-as-a-reverse-proxy-to-glassfish/
#
# https://dzone.com/articles/configure-a-glassfish-cluster-with-automatic-load
# docker
# https://github.com/jelastic-jps/glassfish/

glassfish_asadmin "create-node-ssh --nodehost node['host'] --installdir #{node['glassfish']['base_dir']}/versions/current master" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end
