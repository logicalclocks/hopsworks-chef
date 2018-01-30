#
# For the Hopsworks Virtualbox Instance, autologin and autostart a browser.
# Only for Ubuntu 
#

package 'lightdm'
package 'ubuntu-desktop'
package "mingetty"

bash 'mkdir_autostart' do
  user 'root'
  ignore_failure true
  code <<-EOF
       mkdir -p /home/#{node['glassfish']['user']}/.config/autostart
       chown -R #{node['glassfish']['user']}  /home/#{node['glassfish']['user']}/.config
       groupadd -r autologin
       gpasswd -a #{node['glassfish']['user']} autologin
    EOF
end


#
# Firefox desktop entry should start after hops-services.desktop.
# Change firefox name to 'x' so that it starts last.
#  
template "/home/#{node['glassfish']['user']}/.config/autostart/x-firefox.desktop" do
    source "virtualbox/firefox.desktop.erb"
    owner node['glassfish']['user']
    mode 0774
    action :create
end

template "/home/#{node['glassfish']['user']}/.config/autostart/hops-services.desktop" do
    source "virtualbox/hops-services.desktop.erb"
    owner node['glassfish']['user']
    mode 0774
    action :create
end


  
template "/etc/init/tty1.conf" do
    source "virtualbox/tty.conf.erb"
    owner "root"
    mode 0644
    action :create
end 
  
template "/etc/lightdm/lightdm.conf" do
    source "virtualbox/lightdm.conf.erb"
    owner "root"
    mode 0644
    action :create
end 



#
#
#

service "lightdm" do
  service_name node["lightdm"]["service_name"]
  action [:enable, :start]
end
