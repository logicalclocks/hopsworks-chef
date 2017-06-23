#
# For the Hopsworks Virtualbox Instance, autologin and autostart a browser.
# Only for Ubuntu 
#

package 'ubuntu-desktop'
package "mingetty"

bash 'mkdir_autostart' do
  user 'root'  
  code <<-EOF
       mkdir -p /home/#{node["glassfish"]["user"]}/.config/autostart
       chown -R #{node["glassfish"]["user"]}  /home/#{node["glassfish"]["user"]}/.config
    EOF
end

  
template "/home/#{node['glassfish']['user']}/.config/autostart/google-chrome.desktop" do
    source "virtualbox/google-chrome.desktop.erb"
    owner node["glassfish"]["user"]
    mode 0774
    action :create
end

template "/home/#{node['glassfish']['user']}/.config/autostart/hops-services.desktop" do
    source "virtualbox/hops-services.desktop.erb"
    owner node["glassfish"]["user"]
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

