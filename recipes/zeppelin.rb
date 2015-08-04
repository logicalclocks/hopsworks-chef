

 template "#{node[:zeppelin][:home]}/conf/zeppelin-site.xml" do
   source "zeppelin-site.xml.erb"
   owner node[:zeppelin][:user]
   group node[:hadoop][:group]
   mode 0755
   action :create
 end

 template "#{node[:zeppelin][:home]}/conf/zeppelin-env.sh" do
   source "zeppelin-env.sh.erb"
   owner node[:zeppelin][:user]
   group node[:hadoop][:group]
   mode 0755
   action :create
 end
