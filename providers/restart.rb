
notifying_action :restart do

bash "restart_domain1" do
   user "root"
   ignore_failure true
   code <<-EOF
# This command below is killing other java processes
#   ps -ef | grep glassfish | grep -v grep | awk '{print $2}' | xargs kill -9 
#   /sbin/stop glassfish-domain1
   service glassfish stop 
   sleep 5
#  #{node[:glassfish][:base_dir]}/glassfish/bin/asadmin --user admin --passwordfile #{node[:glassfish][:domains_dir]}/domain1_admin_passwd start-domain domain1
#   /sbin/start glassfish-domain1
   service glassfish start
  EOF
end

end


notifying_action :alter_tables do

exec = "#{node[:ndb][:scripts_dir]}/mysql-client.sh"
cached_kthfsmgr_filename = "#{Chef::Config[:file_cache_path]}/hop-dashboard.war"

bash "redeploy_app_to_create_tables" do
  user node[:glassfish][:user]
  group node[:glassfish][:group]
   code <<-EOF
   #{node[:glassfish][:base_dir]}/glassfish/bin/asadmin --user admin --passwordfile #{node[:glassfish][:domains_dir]}/domain1_admin_passwd undeploy HopsHub 
   #{node[:glassfish][:base_dir]}/glassfish/bin/asadmin --user admin --passwordfile #{node[:glassfish][:domains_dir]}/domain1_admin_passwd deploy --enabled=true --upload=true --availabilityenabled=true --verify=true --force=true --name HopsHub #{cached_kthfsmgr_filename}
  EOF
    not_if "#{exec} kthfs \"show tables\" | grep -i Alerts"
end

bash "alter_table_to_ndb" do
   user "root"
   code <<-EOF

   #{exec} kthfs -e \"source #{new_resource.alter_path}\"
  EOF
    not_if "#{exec} kthfs \"show create table USERS;\" | grep -i ndbcluster"
end


end
