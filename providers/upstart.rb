notifying_action :generate do

  domain_name="#{new_resource.domain_name}"
  admin_pwd="#{new_resource.admin_pwd}"
  username="#{new_resource.username}"

  bash "add_upstart_startup_script" do
    user node.glassfish.user
    group node.glassfish.group
    code <<-EOF
   cd #{node.glassfish.base_dir}/glassfish/bin
   ./asadmin --user #{node.hopsworks.admin.user} --passwordfile #{admin_pwd} --terse start-domain --dry-run > start-domain.java_command
#  -i updates the file inplace. Replace all new-lines with spaces.
#   sed -i ':a;N;$!ba;s/\\n/ /g' start-domain.java_command
   perl -pi -e "s/\\n/ /g" start-domain.java_command
   echo '#!/bin/sh
    echo -e \n
    ' > upstart-exec.sh
   cat start-domain.java_command >> upstart-exec.sh
   echo "&> #{node.glassfish.base_dir}/glassfish/domains/#{domain_name}/logs/server.log &"
   chmod +x upstart-exec.sh
   EOF
  not_if { ::File.exists?( "#{node.glassfish.base_dir}/glassfish/bin/start-domain.java_command")}
  end
 

#update passwordfile to include correct master password

# update to new upstart script
 file "/etc/init/glassfish-#{domain_name}.conf" do
   action :delete
 end

template "/etc/init/glassfish-#{domain_name}.conf" do
  case node['platform_family']
  when "debian"
    source "glassfish-upstart-hop.conf.erb"
  when "rhel"
    source "glassfish-upstart-hop-rhel.conf.erb"
  else
    fail RuntimeError("I don't know how to install chef-server packages for platform family '#{node["platform_family"]}'!")
  end
  mode "0644"
  cookbook 'hopsworks'
  variables(:domain_name => "#{domain_name}", :username => "#{username}", :password_file => "#{admin_pwd}", :listen_ports => [node.glassfish.port, node.glassfish.admin.port],
  :command => "#{node.glassfish.base_dir}/glassfish/bin/start-domain.java_command")
end

end
