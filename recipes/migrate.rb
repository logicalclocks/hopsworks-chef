expat_filename = ::File.basename(node['hopsworks']['expat_url'])
expat_file = "#{Chef::Config['file_cache_path']}/#{expat_filename}"

remote_file expat_file do
  source node['hopsworks']['expat_url']
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory node['hopsworks']['expat_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

bash "extract" do
  user "root"
  code <<-EOH
    tar xf #{expat_file} -C #{node['hopsworks']['expat_dir']} --strip-components=1
    touch #{node['hopsworks']['expat_dir']}/.expat_extracted
  EOH
  action :run
  not_if {::File.exist?("#{node['hopsworks']['expat_dir']}/.expat_extracted")}
end

remote_file "#{node['hopsworks']['expat_dir']}/lib/mysql-connector-java.jar" do
  source node['hopsworks']['mysql_connector_url']
  owner 'root'
  group 'root'
  mode '0750'
  action :create
end

mysql_ip = private_recipe_ip("ndb", "mysqld")
template_version=node['install']['version'].gsub(/\./, '')
template_version=template_version.gsub(/"-SNAPSHOT"/, '')
template "#{node['hopsworks']['expat_dir']}/etc/expat-site.xml" do
  source "migrations/expat-site#{template_version}.xml.erb"
  owner 'root'
  mode '0750'
  variables ({
    mysql_ip: mysql_ip
  })
  action :create
end

bash 'run-expat' do
  user "root"
  environment ({'HADOOP_HOME' => node['hops']['base_dir'],
                'HOPSWORKS_EAR_HOME' => "#{node['hopsworks']['domains_dir']}/#{node['hopsworks']['domain_name']}/applications/hopsworks-ear~#{node['install']['version']}"}) 
  code <<-EOH
    #{node['hopsworks']['expat_dir']}/bin/expat -a migrate -v #{node['install']['version']}
  EOH
  action :run
end