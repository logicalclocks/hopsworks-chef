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

kibana_url = get_kibana_url()
elastic_url = any_elastic_url()
hopsworks_url = "https://#{private_recipe_ip("hopsworks", "default")}:#{node['hopsworks']['https']['port']}"
serviceJwt, _ = get_service_jwt()
template "#{node['hopsworks']['expat_dir']}/etc/expat-site.xml" do
  source "expat-site.xml.erb"
  owner 'root'
  mode '0750'
  variables ({
    :kibana_url => kibana_url,
    :hopsworks_url => hopsworks_url,
    :hopsworks_service_jwt => serviceJwt,
    :elastic_url => elastic_url
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

bash "set_project_storage_type" do
  user node['hops']['hdfs']['user']
  code <<-EOH
    #{node['hops']['bin_dir']}/hdfs storagepolicies -setStoragePolicy -path /Projects -policy DB 
  EOH
  action :run
  only_if "#{node['hops']['bin_dir']}/hdfs dfs -test -d /Projects"
end
