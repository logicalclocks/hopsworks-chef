action :glassfish_configure_network do 

  domain_name=new_resource.domain_name
  password_file=new_resource.password_file
  username=new_resource.username
  admin_port=new_resource.admin_port
  target=new_resource.target
  asadmin=new_resource.asadmin
  internal_port=new_resource.internal_port
  securityenabled=new_resource.securityenabled
  network_name=new_resource.network_name

  asadmin_cmd="#{asadmin} --user #{username} --passwordfile #{password_file}"
  
  # add new network listener for Hopsworks to listen on an internal port
  glassfish_asadmin "create-protocol --securityenabled=#{securityenabled} --target #{target} #{network_name}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin_cmd} list-protocols #{target} | grep #{network_name}"
  end
  
  glassfish_asadmin "create-http --default-virtual-server server --target #{target} #{network_name}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin_cmd} get #{target}.network-config.protocols.protocol.#{network_name}.* | grep 'http.uri-encoding'"
  end
  
  glassfish_asadmin "create-network-listener --listenerport #{internal_port} --threadpool http-thread-pool --target #{target} --protocol #{network_name} #{network_name}-list" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin_cmd} list-http-listeners #{target} | grep #{network_name}-list"
  end
end

action :glassfish_configure_monitoring do 

  domain_name=new_resource.domain_name
  password_file=new_resource.password_file
  username=new_resource.username
  admin_port=new_resource.admin_port
  target=new_resource.target
  asadmin=new_resource.asadmin

  # Enable JMX metrics
  # https://glassfish.org/docs/5.1.0/administration-guide/monitoring.html
  glassfish_asadmin "set-monitoring-configuration --target #{target} --enabled=true --mbeansenabled=true --amxenabled=true --jmxlogfrequency=15 --jmxlogfrequencyunit=SECONDS --dynamic=true" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end

  # Enable Rest metrics
  # --securityenabled=true Configured file realm com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm is not supported.
  glassfish_asadmin "set-metrics-configuration --target #{target} --enabled=true --dynamic=true" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end

  glassfish_asadmin "set-monitoring-level --target #{target} --module=jvm,connector-service,connector-connection-pool,jdbc-connection-pool,web-services-container,thread-pool,http-service,security,jersey,transaction-service,jpa,web-container --level=HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end
end

action :glassfish_configure do 

  domain_name=new_resource.domain_name
  domains_dir=new_resource.domains_dir
  password_file=new_resource.password_file
  username=new_resource.username
  admin_port=new_resource.admin_port
  target=new_resource.target
  asadmin=new_resource.asadmin
  override=new_resource.override_props

  asadmin_cmd="#{asadmin} --terse=false --echo=false --user #{username} --passwordfile #{password_file}"

  glassfish_conf = {
    "#{target}.security-service.default-realm" => 'kthfsrealm',
    # Jobs in Hopsworks use the Timer service
    "#{target}.ejb-container.ejb-timer-service.timer-datasource" => 'jdbc/hopsworksTimers',
    "#{target}.ejb-container.ejb-timer-service.property.reschedule-failed-timer" => node['glassfish']['reschedule_failed_timer'],
    "#{target}.http-service.virtual-server.server.property.send-error_1" => "'code=404 path=#{domains_dir}/#{domain_name}/docroot/index.html reason=Resource_not_found'",
    # Enable/Disable HTTP listener
    "configs.config.#{target}.network-config.network-listeners.network-listener.http-listener-1.enabled" => false,
    # Make sure the https listener is listening on the requested port
    "configs.config.#{target}.network-config.network-listeners.network-listener.http-listener-2.port" => node['hopsworks']['https']['port'],
    "configs.config.#{target}.network-config.protocols.protocol.http-listener-2.http.http2-enabled" => false,
    "configs.config.#{target}.network-config.protocols.protocol.https-internal.http.http2-enabled" => false,
    # Disable X-Powered-By and server headers
    "configs.config.#{target}.network-config.protocols.protocol.http-listener-2.http.server-header" => false,
    "configs.config.#{target}.network-config.protocols.protocol.http-listener-2.http.xpowered-by" => false,
    # Disable SSL3
    "#{target}.network-config.protocols.protocol.http-listener-2.ssl.ssl3-enabled" => false,
    "#{target}.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled" => false,
    "#{target}.network-config.protocols.protocol.https-internal.ssl.ssl3-enabled" => false,
    "#{target}.admin-service.jmx-connector.system.ssl.ssl3-enabled" => false,
    "#{target}.iiop-service.iiop-listener.SSL.ssl.ssl3-enabled" => false,
    "#{target}.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-enabled" => false,
    # HTTP-2
    "configs.config.#{target}.network-config.protocols.protocol.http-listener-2.http.http2-push-enabled" => true,
    # Disable TLS 1.0
    "#{target}.network-config.protocols.protocol.http-listener-2.ssl.tls-enabled" => false,
    "#{target}.network-config.protocols.protocol.sec-admin-listener.ssl.tls-enabled" => false,
    "#{target}.network-config.protocols.protocol.https-internal.ssl.tls-enabled" => false,
    "#{target}.admin-service.jmx-connector.system.ssl.tls-enabled" => false,
    "#{target}.iiop-service.iiop-listener.SSL.ssl.tls-enabled" => false,
    "#{target}.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.tls-enabled" => false,
    # Restrict ciphersuite
    "configs.config.#{target}.network-config.protocols.protocol.http-listener-2.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
    "configs.config.#{target}.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
    "configs.config.#{target}.network-config.protocols.protocol.https-internal.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
    "#{target}.admin-service.jmx-connector.system.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
    "#{target}.iiop-service.iiop-listener.SSL.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
    "#{target}.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-tls-ciphers" => node['glassfish']['ciphersuite'],
    # Set correct thread-priority for the executor services - required during updates
    "resources.managed-executor-service.concurrent\/hopsExecutorService.thread-priority" => 10,
    "resources.managed-thread-factory.concurrent\/hopsThreadFactory.thread-priority" => 10,
    "resources.managed-executor-service.concurrent\/condaExecutorService.thread-priority" => 9,
    "resources.managed-executor-service.concurrent\/jupyterExecutorService.thread-priority" => 8,
    # Enable Single Sign on
    "configs.config.#{target}.http-service.virtual-server.server.sso-enabled" => true,
    "configs.config.#{target}.http-service.virtual-server.server.sso-cookie-http-only" => true,
    # Allow following symlinks from docroot
    "#{target}.http-service.virtual-server.server.property.allowLinking" => true,
    "#{target}.network-config.protocols.protocol.http-listener-2.http.timeout-seconds" => node['glassfish']['http']['keep_alive_timeout'],
    "#{target}.network-config.protocols.protocol.http-listener-1.http.timeout-seconds" => node['glassfish']['http']['keep_alive_timeout'],
    "#{target}.network-config.protocols.protocol.https-internal.http.timeout-seconds" => node['glassfish']['http']['keep_alive_timeout'],
    "resources.jdbc-connection-pool.hopsworksPool.property.User" => node['hopsworks']['mysql']['user'],
    "resources.jdbc-connection-pool.hopsworksPool.property.Password" => node['hopsworks']['mysql']['password'],
    "resources.jdbc-connection-pool.hopsworksPool.property.useSSL" => 'false',
    "resources.jdbc-connection-pool.hopsworksPool.property.allowPublicKeyRetrieval" => 'true',
    "resources.jdbc-connection-pool.ejbTimerPool.property.User" => node['hopsworks']['mysql']['user'],
    "resources.jdbc-connection-pool.ejbTimerPool.property.Password" => node['hopsworks']['mysql']['password'],
    "resources.jdbc-connection-pool.ejbTimerPool.property.useSSL" => 'false',
    "resources.jdbc-connection-pool.ejbTimerPool.property.allowPublicKeyRetrieval" => 'true',
    "#{target}.network-config.protocols.protocol.https-internal.ssl.cert-nickname" => 'internal',
    # The timeout, in seconds, for requests. A value of -1 will disable it.
    "#{target}.network-config.protocols.protocol.http-listener-2.http.request-timeout-seconds" => node['glassfish']['http']['request-timeout-seconds'],
    "#{target}.network-config.protocols.protocol.http-listener-1.http.request-timeout-seconds" => node['glassfish']['http']['request-timeout-seconds']
  }

  override.each { |k, v| glassfish_conf[k] = v } 
  
  glassfish_conf.each do |property, value|
    glassfish_asadmin "set #{property}=#{value}" do
     domain_name domain_name
     password_file password_file
     username username
     admin_port admin_port
     secure false
    end
  end

  glassfish_asadmin "set configs.config.#{target}.cdi-service.enable-concurrent-deployment=true" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end
  
  glassfish_asadmin "set configs.config.#{target}.cdi-service.pre-loader-thread-pool-size=#{node['glassfish']['ejb_loader']['thread_pool_size']}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end
end

action :glassfish_configure_realm do
  domain_name=new_resource.domain_name
  password_file=new_resource.password_file
  username=new_resource.username
  admin_port=new_resource.admin_port
  target=new_resource.target
  asadmin=new_resource.asadmin
  realmname = "kthfsrealm"
  jndiDB = "jdbc/hopsworks"

  asadmin_cmd="#{asadmin} --user #{username} --passwordfile #{password_file}"

  props =  {
    'datasource-jndi' => jndiDB,
    'password-column' => 'password',
    'group-table' => 'hopsworks.users_groups',
    'user-table' => 'hopsworks.users',
    'group-name-column' => 'group_name',
    'user-name-column' => 'email',
    'group-table-user-name-column' => 'email',
    'encoding' => 'Hex',
    'digestrealm-password-enc-algorithm' => 'SHA-256',
    'digest-algorithm' => 'SHA-256'
  }
  
  glassfish_auth_realm "#{realmname}" do
    target target
    realm_name "#{realmname}"
    jaas_context "jdbcRealm"
    properties props
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    classname "com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm"
    not_if "#{asadmin_cmd} list-auth-realms #{target} | grep kthfsrealm"
  end
end

action :change_node_master_password do
  username=new_resource.username
  asadmin=new_resource.asadmin
  nodedir=new_resource.nodedir
  node_name=new_resource.node_name
  current_password=new_resource.current_master_password
  # Option "savemasterpassword" for change-master-password is always true for nodes.
  bash "change-master-password" do 
    user "#{node['glassfish']['user']}"
    cwd "/tmp"
    code <<-EOH
      set -e
      echo -e 'AS_ADMIN_PASSWORD=#{node['hopsworks']['admin']['password']}\nAS_ADMIN_MASTERPASSWORD=#{current_password}' > masterpwdfile

      /usr/bin/expect <<EOF
      spawn #{asadmin} --user #{username} --passwordfile masterpwdfile change-master-password --nodedir #{nodedir} #{node_name}
      expect "Enter the new master password> "
      send "#{node['hopsworks']['master']['password']}\r"
      expect "Enter the new master password again> "
      send "#{node['hopsworks']['master']['password']}\r"
      expect "$ "
EOF
rm masterpwdfile
EOH
    not_if { ::File.exist?("#{nodedir}/#{node_name}/agent/master-password") }
  end
end