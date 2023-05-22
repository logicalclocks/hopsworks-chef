domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
username=node['hopsworks']['admin']['user']
asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

asadmin_cmd="#{asadmin} --user #{username} --passwordfile #{password_file}"

ssh_nodes= node['hopsworks'].attribute?('ssh_node')? private_recipe_ips('hopsworks', 'ssh_node') : []
config_nodes= node['hopsworks'].attribute?('config_node')? private_recipe_ips('hopsworks', 'config_node') : []
public_ip=my_public_ip()
local_instance="instance0" #list-nodes does not show das node

glassfish_nodes = ssh_nodes + config_nodes
nodes_hash = glassfish_nodes.map{ |x| [x, get_instance_name_by_host(asadmin_cmd, x)] }.to_h

puts ("glassfish_nodes #{glassfish_nodes}, #{nodes_hash}")

# Install load balancer
case node['platform_family']
when "debian"
  package "apache2" do
    retries 10
    retry_delay 30
  end
  template "/etc/apache2/sites-available/loadbalancer.conf"  do
    source 'loadbalancer.conf.erb'
    user 'root'
    action :create
    variables({
      :load_balancer_port => "#{node['hopsworks']['ha']['loadbalancer_port']}",
      :load_balancer_log_dir => "/var/log/apache2",
      :public_ip => public_ip,
      :local_instance => local_instance,
      :glassfish_nodes => nodes_hash
    })
  end

  bash "configure load balancer" do
    user 'root'
    code <<-EOF
      sed -i 's/Listen 80$/Listen #{node['hopsworks']['ha']['loadbalancer_port']}/' /etc/apache2/ports.conf 
      a2enmod proxy_http
      a2enmod proxy_balancer proxy_wstunnel lbmethod_byrequests rewrite
      a2dissite 000-default.conf
      a2ensite loadbalancer.conf
      systemctl restart apache2
    EOF
  end
when "rhel"
  package ["httpd", "mod_ssl"] do
    retries 10
    retry_delay 30
  end
  directory "/etc/httpd/sites-available" do
    user 'root'
    action :create
    not_if { ::File.directory?('/etc/httpd/sites-available') }
  end
  directory "/etc/httpd/sites-enabled" do
    user 'root'
    action :create
    not_if { ::File.directory?('/etc/httpd/sites-enabled') }
  end

  template "/etc/httpd/sites-available/loadbalancer.conf"  do
    source 'loadbalancer.conf.erb'
    user 'root'
    action :create
    variables({
      :load_balancer_port => "#{node['hopsworks']['ha']['loadbalancer_port']}",
      :load_balancer_log_dir => "/var/log/httpd",
      :public_ip => public_ip,
      :local_instance => local_instance,
      :glassfish_nodes => nodes_hash
    })
  end

  bash "configure load balancer" do
    user 'root'
    code <<-EOF
      sed -i 's/Listen 80$/Listen #{node['hopsworks']['ha']['loadbalancer_port']}/' /etc/httpd/conf/httpd.conf
      echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf
      ln -s /etc/httpd/sites-available/loadbalancer.conf /etc/httpd/sites-enabled/loadbalancer.conf
      systemctl restart httpd
    EOF
    not_if { ::File.exist?('/etc/httpd/sites-enabled/loadbalancer.conf') }
  end
end