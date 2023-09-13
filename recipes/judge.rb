directory node['judge']['home'] do
    owner 'root'
    group 'root'
    mode '0750'
end

directory node['judge']['etc'] do
    owner 'root'
    group 'root'
    mode '0750'
end

directory node['judge']['logs'] do
    owner 'root'
    group 'root'
    mode '0750'
end

template "#{node['judge']['etc']}/default.conf" do
    source "judge/default.conf.erb"
    owner 'root'
    group 'root'
    mode 0750
end

file "#{node['judge']['logs']}/access.log" do
    owner 'root'
    group 'root'
    mode 0750
end

file "#{node['judge']['logs']}/error.log" do
    owner 'root'
    group 'root'
    mode 0750
end

filename = File.basename(node['judge']['image_url'])
remote_file "#{Chef::Config['file_cache_path']}/#{filename}" do
    source node['judge']['image_url']
end

bash "import-judge-image" do
    user "root"
    code <<-EOF
      docker load -i #{Chef::Config['file_cache_path']}/#{filename}
    EOF
end

systemd_unit "judge.service" do
    action :stop
end

case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/judge.service"
else
  systemd_script = "/lib/systemd/system/judge.service"
end

template systemd_script do
    source "judge/judge.service.erb"
    owner "root"
    group "root"
    mode 0664
end

kagent_config 'judge' do
    service "judge"
    restart_agent false
    action :add
end

systemd_unit "judge.service" do
    action [:enable, :start]
end