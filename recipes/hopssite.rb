#START hopssite install scripts
begin
  elastic_ip = private_recipe_ip("elastic","default")
rescue
  elastic_ip = ""
  Chef::Log.warn "could not find the elastic server ip for HopsWorks!"
end

directory node['hopssite']['home'] do
  owner node['glassfish']['user']
  mode 0755
  action :create
end

template "#{node['hopssite']['home']}/hs_env.sh" do
  source "hopssite/hs_env.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_install.sh" do
  source "hopssite/hs_install.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_setup.sh" do
  source "hopssite/hs_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_db_setup.sh" do
  source "hopssite/hs_db_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_create_domain2.sh" do
  source "hopssite/hs_create_domain2.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_jdbc_connector.sh" do
  source "hopssite/hs_jdbc_connector.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_realm_setup.sh" do
  source "hopssite/hs_realm_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_domain2_certs.sh" do
  source "hopssite/hs_domain2_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_glassfish_sign.sh" do
  source "hopssite/hs_glassfish_sign.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_glassfish_certs.sh" do
  source "hopssite/hs_glassfish_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_ssl_setup.sh" do
  source "hopssite/hs_ssl_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_admin_certs.sh" do
  source "hopssite/hs_admin_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_redeploy.sh" do
  source "hopssite/hs_redeploy.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_elastic.sh" do
  source "hopssite/hs_elastic.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
  variables({
    :elastic_ip => elastic_ip
    })
end

template "#{node['hopssite']['home']}/hs_dela_certs.sh" do
  source "hopssite/hs_dela_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_purge.sh" do
  source "hopssite/hs_purge.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
  variables({
    :elastic_ip => elastic_ip
    })
end

template "#{node['hopssite']['home']}/hs_tables.sql" do
  source "hopssite/hs_tables.sql.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_rows.sql" do
  source "hopssite/hs_rows.sql.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
  variables({
    :elastic_ip => elastic_ip
    })
end

template "#{node['hopssite']['home']}/glassfish-domain2.service" do
  source "hopssite/glassfish-domain2.service.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_systemctl.sh" do
  source "hopssite/hs_systemctl.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end
#END hopssite install scripts