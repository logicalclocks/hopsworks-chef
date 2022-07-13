action :sign_hopssite do

  signed = "#{node['hopsworks']['domains_dir']}/.hops_site_keystore_signed"

  bash "sign-global-csr-key" do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    code <<-EOF
      set -eo pipefail
      export PYTHON_EGG_CACHE=/tmp
      #{node['conda']['base_dir']}/envs/hops-system/bin/python #{node['hopsworks']['domains_dir']}/domain1/bin/csr-ca.py
      touch #{signed}
  EOF
    not_if { ::File.exists?( "#{signed}" ) }
  end
end

action :generate_int_certs do 

  bash 'generate-internal-key' do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd node['hopsworks']['config_dir']
    code <<-EOH
      openssl genrsa -out internal.key 2048 
      openssl req -new -key internal.key -subj #{new_resource.subject} -out internal.csr
    EOH
  end

  # Sign the certificate
  kagent_pki 'sign-internal-key' do
    csr_file "#{node['hopsworks']['config_dir']}/internal.csr"
    output_dir node['hopsworks']['config_dir']
    action :sign_csr
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
  end

end

action :download_azure_ca_cert do
  # Download azure root CA cert
  remote_file '/tmp/DigiCertGlobalRootG2.crt' do
    source "#{node['hopsworks']['azure-ca-cert']['download-url']}"
    mode '0755'
    action :create
  end

  # Add the certificate to the keystore.jks
  bash "add_to_keystore" do 
    user "root"
    cwd "/tmp"
    code <<-EOH
      set -e
      GFDOMAIN=#{node['glassfish']['domains_dir']}/domain1
      # Import into the keystore
      keytool -import -noprompt -alias digicertglobalrootg2 -file DigiCertGlobalRootG2.crt -keystore $GFDOMAIN/config/cacerts.jks -storepass #{node['hopsworks']['master']['password']}
    EOH
  end
end
