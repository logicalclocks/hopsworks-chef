#
# For the Hopsworks Virtualbox Instance, autologin and autostart a browser.
# Only for Ubuntu 
#

package 'ubuntu-desktop'

template "/home/#{node['glassfish']['user']}/.config/autostart/google-chrome.desktop" do
    source "virtualbox/google-chrome.desktop.erb"
    owner node["glassfish"]["user"]
    mode 0774
    action :create
end 


  
template "/etc/init/tty7.conf" do
    source "virtualbox/tty7.conf.erb"
    owner node["glassfish"]["user"]
    mode 0774
    action :create
end 
  
template "/etc/lightdm/lightdm.conf" do
    source "virtualbox/lightdm.conf.erb"
    owner node["glassfish"]["user"]
    mode 0774
    action :create
end 

