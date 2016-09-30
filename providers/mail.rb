use_inline_resources

notifying_action :jndi do

decoded = node.hopsworks.email_password 

# If the email_password is the 'default' password
if decoded.eql? "password"
  decoded = ::File.read("/tmp/hopsworks.encoded")
  node.override.hopsworks.email_password = decoded
end

gmailProps = {
  'mail-smtp-host' => node.hopsworks.smtp,
  'mail-smtp-user' => node.hopsworks.email,
  'mail-smtp-password' => decoded,
  'mail-smtp-auth' => 'true',
  'mail-smtp-port' => node.hopsworks.smtp_port,
  'mail-smtp-socketFactory-port' => node.hopsworks.smtp_ssl_port,
  'mail-smtp-socketFactory-class' => 'javax.net.ssl.SSLSocketFactory',
  'mail-smtp-starttls-enable' => 'true',
  'mail.smtp.ssl.enable' => 'true',
  'mail-smtp-socketFactory-fallback' => 'false'
}

 Chef::Log.info("gmail password is #{decoded}")

 glassfish_javamail_resource "gmail" do 
   jndi_name "mail/BBCMail"
   mailuser node.hopsworks.email
   mailhost node.hopsworks.smtp
   fromaddress node.hopsworks.email
   properties gmailProps
   domain_name "#{new_resource.domain_name}"
   password_file "#{new_resource.password_file}"
   username "#{new_resource.username}"
   admin_port new_resource.admin_port
   secure false
   action :create
 end


end
