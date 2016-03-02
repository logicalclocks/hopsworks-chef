use_inline_resources

notifying_action :jndi do

decoded = node.hopsworks.gmail.password 

# If the password is the 'default' password
if decoded.eql? "password"
  decoded = ::File.read("/tmp/hopsworks.encoded")
end

gmailProps = {
  'mail-smtp-host' => 'smtp.gmail.com',
  'mail-smtp-user' => node.hopsworks.gmail.email,
  'mail-smtp-password' => decoded,
  'mail-smtp-auth' => 'true',
  'mail-smtp-port' => '587',
  'mail-smtp-socketFactory-port' => '465',
  'mail-smtp-socketFactory-class' => 'javax.net.ssl.SSLSocketFactory',
  'mail-smtp-starttls-enable' => 'true',
  'mail.smtp.ssl.enable' => 'true',
  'mail-smtp-socketFactory-fallback' => 'false'
}

 Chef::Log.info("gmail password is #{decoded}")

 glassfish_javamail_resource "gmail" do 
   jndi_name "mail/BBCMail"
   mailuser node.hopsworks.gmail.email
   mailhost "smtp.gmail.com"
   fromaddress node.hopsworks.gmail.email
   properties gmailProps
   domain_name "#{new_resource.domain_name}"
   password_file "#{new_resource.password_file}"
   username "#{new_resource.username}"
   admin_port new_resource.admin_port
   secure false
   action :create
 end


end
