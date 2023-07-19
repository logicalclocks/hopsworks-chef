action :generate_int_certs do 

  bash 'generate-internal-key' do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd node['hopsworks']['config_dir']
    code <<-EOH
      openssl genrsa -out internal.key 2048 
      openssl req -new -key internal.key -subj #{new_resource.subject} -out internal.csr
    EOH
    not_if { ::File.exist?("#{node['hopsworks']['config_dir']}/internal.key") }
  end

  # Sign the certificate
  kagent_pki 'sign-internal-key' do
    csr_file "#{node['hopsworks']['config_dir']}/internal.csr"
    output_dir node['hopsworks']['config_dir']
    http_port   node['hopsworks']['https']['port'].to_i
    action :sign_csr
    not_if { ::File.exist?("#{node['hopsworks']['config_dir']}/certificate_bundle.pem") }
  end

  # Add the certificate to the keystore.jks
  bash "add_to_keystore" do 
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd node['hopsworks']['config_dir']
    code <<-EOH
        set -e
        openssl pkcs12 -export -in certificate_bundle.pem -inkey internal.key -out cert_and_key.p12 -name internal -CAfile root_ca.pem -caname internal -password pass:#{node['hopsworks']['master']['password']}

        # Import into the keystore
        keytool -importkeystore -destkeystore keystore.jks -srckeystore cert_and_key.p12 -srcstoretype PKCS12 -alias internal -srcstorepass #{node['hopsworks']['master']['password']} -deststorepass #{node['hopsworks']['master']['password']} -destkeypass #{node['hopsworks']['master']['password']}

        keytool -import -noprompt -alias internal -file root_ca.pem -keystore cacerts.jks -storepass #{node['hopsworks']['master']['password']}
    EOH
    not_if "keytool -list -keystore #{node['hopsworks']['config_dir']}/cacerts.jks -alias internal -storepass #{node['hopsworks']['master']['password']}"
  end
end

action :import_certs do

  remote_file "#{node['hopsworks']['config_dir']}/https_key.key" do
    source node['hopsworks']['https']['key_url']
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    mode '0700'
    action :create
  end

  remote_file "#{node['hopsworks']['config_dir']}/https_cert.pem" do
    source node['hopsworks']['https']['cert_url']
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    mode '0700'
    action :create
  end

  unless node['hopsworks']['https']['intermediate_ca_url'].empty?
    remote_file "#{node['hopsworks']['config_dir']}/https_intermediate_ca.pem" do
      source node['hopsworks']['https']['intermediate_ca_url']
      user node['hopsworks']['user']
      group node['hopsworks']['group']
      mode '0700'
      action :create
    end
  end

  remote_file "#{node['hopsworks']['config_dir']}/https_ca.pem" do
    source node['hopsworks']['https']['ca_url']
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    mode '0700'
    action :create
  end

  # Add the certificate to the keystore.jks
  bash "add_to_keystore" do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd node['hopsworks']['config_dir']
    code <<-EOH
        set -e
        openssl pkcs12 -export -in https_cert.pem -inkey https_key.key -out cert_and_key.p12 -name s1as -CAfile https_ca.pem -caname s1as -password pass:#{node['hopsworks']['master']['password']}

        # Remove existing certificate
        keytool -delete -alias s1as -keystore keystore.jks -storepass #{node['hopsworks']['master']['password']}

        # Import into the keystore
        keytool -importkeystore -destkeystore keystore.jks -srckeystore cert_and_key.p12 -srcstoretype PKCS12 -alias s1as -srcstorepass #{node['hopsworks']['master']['password']} -deststorepass #{node['hopsworks']['master']['password']} -destkeypass #{node['hopsworks']['master']['password']}

        # Remove existing certificate
        keytool -delete -alias s1as -keystore cacerts.jks -storepass #{node['hopsworks']['master']['password']}

        # Add Root CA into cacerts.jks
        keytool -import -noprompt -alias s1as -file https_ca.pem -keystore cacerts.jks -storepass #{node['hopsworks']['master']['password']}
    EOH
  end

  bash "add_intermediate_ca" do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd node['hopsworks']['config_dir']
    code <<-EOH
        # Remove existing certificate
        keytool -delete -alias s1as-intermediate -keystore cacerts.jks -storepass #{node['hopsworks']['master']['password']}

        set -e
        # Add intermediate Root CA into cacerts.jks
        keytool -import -noprompt -alias s1as-intermediate -file https_intermediate_ca.pem -keystore cacerts.jks -storepass #{node['hopsworks']['master']['password']}
    EOH
    not_if { node['hopsworks']['https']['intermediate_ca_url'].empty? }
  end

  # Enable and disable secure admin to get it to pick up the new certificate
  # If we don't do this, users won't be able to log in through the admin UI.
  # We don't need to restart glassfish here as it's one immediately after by the recipes
  glassfish_asadmin "disable-secure-admin" do
    domain_name node['hopsworks']['domain_name']
    password_file "#{node['hopsworks']['domains_dir']}/#{node['hopsworks']['domain_name']}_admin_passwd"
    username node['hopsworks']['admin']['user']
    admin_port node['hopsworks']['admin']['port']
    secure false
  end

  glassfish_asadmin "enable-secure-admin" do
    domain_name node['hopsworks']['domain_name']
    password_file "#{node['hopsworks']['domains_dir']}/#{node['hopsworks']['domain_name']}_admin_passwd"
    username node['hopsworks']['admin']['user']
    admin_port node['hopsworks']['admin']['port']
    secure false
  end
end


action :download_azure_ca_cert do
  # Download azure root CA cert
  remote_file '/tmp/DigiCertGlobalRootG2.crt' do
    source node['hopsworks']['azure-ca-cert']['download-url']
    mode '0755'
    action :create
  end

  # Add the certificate to the keystore.jks
  bash "add_to_keystore" do 
    user "root"
    cwd "/tmp"
    code <<-EOH
      set -e
      GFDOMAIN=#{node['hopsworks']['config_dir']}
      # Import into the keystore
      keytool -import -noprompt -alias digicertglobalrootg2 -file DigiCertGlobalRootG2.crt -keystore $GFDOMAIN/cacerts.jks -storepass #{node['hopsworks']['master']['password']}
    EOH
    not_if "keytool -list -keystore #{node['hopsworks']['config_dir']}/cacerts.jks -alias digicertglobalrootg2 -storepass #{node['hopsworks']['master']['password']}"
  end
end
