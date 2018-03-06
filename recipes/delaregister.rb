directory node['hopssite']['home'] do
  owner node['hopsworks']['user']
  mode 0755
  action :create
end

template "#{node['hopssite']['home']}/register.sh" do
  source "dela/register.sh.erb"
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/register_data.json" do
  source "dela/register_data.json.erb"
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  action :create
  mode 0644
end

bash "register" do
  user node['hopsworks']['user']
  code <<-EOF
    set -e
    #{node['hopssite']['home']}/register.sh
  EOF
end