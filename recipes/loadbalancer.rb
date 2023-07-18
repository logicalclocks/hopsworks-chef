domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
username=node['hopsworks']['admin']['user']
asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

admin_port = node['hopsworks']['admin']['port']
das_ip=private_recipe_ip('hopsworks', 'das_node')
asadmin_cmd="#{asadmin} --host #{das_ip} --port #{admin_port} --user #{username} --passwordfile #{password_file}"

config_nodes= node['hopsworks'].attribute?('config_node')? private_recipe_ips('hopsworks', 'config_node') : []

glassfish_nodes = config_nodes.map{ |x| [x, get_instance_name_by_host(asadmin_cmd, x)] }.to_h
glassfish_nodes[das_ip]="instance0" # get_instance_name_by_host will not work for das node b/c host is localhost not ip

# Install load balancer
case node['platform_family']
when "debian"
  package "apache2" do
    action :purge
  end
  package ["libnginx-mod-stream", "nginx"] do
    retries 10
    retry_delay 30
  end
  template "/etc/nginx/nginx.conf"  do
    source 'nginx.conf.erb'
    user 'root'
    action :create
    variables({
      :load_balancer_port => "#{node['hopsworks']['ha']['loadbalancer_port']}",
      :load_balancer_log_dir => "/var/log/nginx",
      :glassfish_nodes => glassfish_nodes,
      :load_module => "/usr/lib/nginx/modules/ngx_stream_module.so"
    })
  end

  bash "restart load balancer" do
    user 'root'
    code <<-EOF
      systemctl restart nginx
    EOF
  end
when "rhel"
  package ["httpd", "mod_ssl"] do
    action :purge
  end
  bash "configure load balancer" do
    user 'root'
    code <<-EOF
      yum module enable nginx:1.22 -y
    EOF
  end

  package ["nginx", "nginx-mod-stream"] do
    retries 10
    retry_delay 30
  end

  template "/etc/nginx/nginx.conf"  do
    source 'nginx.conf.erb'
    user 'root'
    action :create
    variables({
      :load_balancer_port => "#{node['hopsworks']['ha']['loadbalancer_port']}",
      :load_balancer_log_dir => "/var/log/nginx",
      :glassfish_nodes => glassfish_nodes,
      :load_module => "/usr/lib64/nginx/modules/ngx_stream_module.so"
    })
  end

  bash "enable and start load balancer" do
    user 'root'
    code <<-EOF
      systemctl enable nginx
      systemctl start nginx
    EOF
  end
end