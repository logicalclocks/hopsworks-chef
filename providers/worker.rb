action :add_to_services do
  asadmin=new_resource.asadmin
  admin_port=new_resource.admin_port
  username=new_resource.username
  password_file=new_resource.password_file
  nodedir=new_resource.nodedir
  node_name=new_resource.node_name
  instance_name=new_resource.instance_name
  service_name=new_resource.service_name
  systemd_start_timeout=new_resource.systemd_start_timeout
  systemd_stop_timeout=new_resource.systemd_stop_timeout

  domain_name = node['hopsworks']['domain_name']

  start_instance_command = "#{asadmin} --user #{username} --passwordfile #{password_file} start-local-instance --sync normal --nodedir #{nodedir}"
  restart_instance_command = "#{asadmin} --user #{username} --passwordfile #{password_file} restart-local-instance --nodedir #{nodedir}"
  stop_instance_command = "#{asadmin} --user #{username} --passwordfile #{password_file} stop-local-instance --nodedir #{nodedir}"

  kagent_config "glassfish-#{domain_name}" do
    service "glassfish_#{domain_name}"
    role service_name
    log_file "#{nodedir}/#{node_name}/#{instance_name}/logs/server.log"
    restart_agent true
    only_if {node['kagent']['enabled'].casecmp? "true"}
    only_if { ::File.directory?("#{nodedir}")}
  end

  #we hard code systemd enabled in install.rb
  template "/lib/systemd/system/#{service_name}.service" do
    source 'systemd.service.erb'
    mode '0644'
    cookbook 'hopsworks'

    variables(start_domain_command: "#{start_instance_command}",
              restart_domain_command: "#{restart_instance_command}",
              stop_domain_command: "#{stop_instance_command}",
              start_domain_timeout: systemd_start_timeout,
              stop_domain_timeout: systemd_stop_timeout,
              authbind: new_resource.requires_authbind)
    notifies :start, "service[#{service_name}]", :delayed
  end
  if node['services']['enabled'].casecmp?("true")
    service service_name do
      supports start: true, restart: true, stop: true, status: true
      action [:enable]
    end
  end
end

action :configure_node do
  asadmin=new_resource.asadmin
  admin_port=new_resource.admin_port
  username=new_resource.username
  password_file=new_resource.password_file
  nodedir=new_resource.nodedir
  node_name=new_resource.node_name
  instance_name=new_resource.instance_name

  log_dir="#{nodedir}/#{node_name}/#{instance_name}/logs"
  data_volume_logs_dir="#{node['hopsworks']['data_volume']['root_dir']}/#{node_name}/logs"

  directory "#{node['hopsworks']['data_volume']['root_dir']}/#{node_name}" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode '0750'
  end

  directory "#{data_volume_logs_dir}" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode '0750'
  end

  link "#{log_dir}" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode '0750'
    to data_volume_logs_dir
  end

  bash "create_users_groups_view" do
    user "root"
    code <<-EOH
      #{node['ndb']['scripts_dir']}/mysql-client.sh --database=hopsworks -e \"CREATE OR REPLACE ALGORITHM=UNDEFINED VIEW users_groups AS select u.username AS username,u.password AS password,u.secret AS secret,u.email AS email,g.group_name AS group_name from ((user_group ug join users u on((u.uid = ug.uid))) join bbc_group g on((g.gid = ug.gid)));\" 
    EOH
  end

  # Register Glassfish with Consul
  consul_service "Registering Glassfish worker with Consul" do
    service_definition "consul/glassfish-worker-consul.hcl.erb"
    reload_consul false
    action :register
  end

  # We can't use the internal port yet as the certificate has not been generated yet
  hopsworks_certs "generate-int-certs" do
    subject     "/CN=#{node['fqdn']}/L=glassfishinternal/OU=0"
    action      :generate_int_certs
  end

  hopsworks_certs "import-user-certs" do
    action :import_certs
    skip_secure_admin true 
    not_if { node['hopsworks']['https']['key_url'].eql?("") }
  end

  hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node["hopsworks"]["internal"]["port"]}"
  kagent_hopsify "Generate x.509" do
    user node['hopsworks']['user']
    crypto_directory x509_helper.get_crypto_dir(node['hopsworks']['user'])
    hopsworks_alt_url hopsworks_alt_url
    action :generate_x509
  end
end