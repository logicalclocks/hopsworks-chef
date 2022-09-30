#make cadvisor dir
directory "#{node['hops']['cadvisor']['dir']}" do
  owner "root"
  group "root"
  mode "0700"
  action :create
  not_if { ::File.directory?(node['hops']['cadvisor']['dir']) }
end

# download cadvisor bin
cadvisor_bin_url = node['hops']['cadvisor']['download-url']
bin_name = File.basename(cadvisor_bin_url)
cadvisor_bin = "#{node['hops']['cadvisor']['dir'] }/#{bin_name}"

remote_file cadvisor_bin do
  source cadvisor_bin_url
  owner "root"
  mode "0755"
  action :create_if_missing
end


service_name = "cadvisor"

case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/#{service_name}.service"
else
  systemd_script = "/lib/systemd/system/#{service_name}.service"
end

service service_name do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template systemd_script do
  source "#{service_name}.service.erb"
  owner "root"
  group "root"
  mode 0664
  if node['services']['enabled'] == "true"
    notifies :enable, "service[#{service_name}]"
  end
  notifies :restart, "service[#{service_name}]"
  variables({
              'cadvisor_bin' => cadvisor_bin
            })
end

kagent_config "#{service_name}" do
  action :systemd_reload
end

# Register with kagent
if node['kagent']['enabled'] == "true"
  kagent_config "#{service_name}" do
    service "#{service_name}"
    restart_agent false
    action :add
  end
end


if service_discovery_enabled()
  # Register cAdvisor with Consul
  consul_service "Registering cAdvisor with Consul" do
    service_definition "consul/cadvisor-consul.hcl.erb"
    action :register
  end
end