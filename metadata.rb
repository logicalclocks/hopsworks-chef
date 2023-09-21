name             "hopsworks"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      "Installs/Configures HopsWorks, the UI for Hops Hadoop."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.5.0"
source_url       "https://github.com/logicalclocks/hopsworks-chef"


%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

depends 'compat_resource', '~> 12.19.0'
depends 'authbind', '~> 0.1.10'
depends 'ntp', '~> 2.0.0'
depends 'sysctl', '~> 1.0.3'
depends 'seven_zip', '~> 3.2.0'
depends 'conda'
depends 'kagent'
depends 'hops'
depends 'ndb'
depends 'hadoop_spark'
depends 'flink'
depends 'livy'
depends 'epipe'
depends 'tensorflow'
depends 'kzookeeper'
depends 'kkafka'
depends 'elastic'
depends 'hopslog'
depends 'hopsmonitor'
depends 'hops_airflow'
depends 'hive2'
depends 'consul'
depends 'glassfish'
depends 'kube-hops'
depends 'onlinefs'
depends 'java'


recipe  "hopsworks::install", "Installs Glassfish"

recipe  "hopsworks", "Installs HopsWorks war file, starts glassfish+application."
recipe  "hopsworks::dev", "Installs development libraries needed for HopsWorks development."
recipe  "hopsworks::letsencypt", "Given a glassfish installation and a letscrypt installation, update glassfish's key."
recipe  "hopsworks::image", "Prepare for use as a virtualbox image."
recipe  "hopsworks::rollback", "Rollback an upgrade to Hopsworks."

recipe  "hopsworks::migrate", "Call expat to migrate between Hopsworks versions"

recipe  "hopsworks::purge", "Deletes glassfish installation."
recipe  "hopsworks::reindex", "Reindex the featurestore search index"
#######################################################################################
# Required Attributes
#######################################################################################

attribute "hopsworks/default/private_ips",
          :description => "ip addrs",
          :type => 'array'

attribute "hopsworks/admin/email",
          :description => "Email address of the default admin user",
          :type => 'string'

attribute "hopsworks/email",
          :description => "Email account to send notifications from. ",
          :required => "required",
          :type => 'string'

attribute "hopsworks/email_password",
          :description => "Password for email account. ",
          :required => "required",
          :type => 'string'

attribute "hopsworks/twofactor_auth",
          :description => "Ip Address/hostname of SMTP server (default is smtp.gmail.com)",
          :type => 'string'

attribute "hopsworks/cert_mater_delay",
          :description => "Delay for the Certificate Materialization service of Hopsworks to delete the certificates from the local fs",
          :type => 'string'

attribute "hopsworks/service_key_rotation_enabled",
          :description => "Configuration option to enable/disable automatic service key rotation",
          :type => 'string'

attribute "hopsworks/service_key_rotation_interval",
          :description => "Interval for Hops service certificates rotation",
          :type => 'string'

attribute "hopsworks/application_certificate_validity_period",
          :description => "Application certificate validity period. Certificates will be rotated well before the expiration",
          :type => 'string'

attribute "hopsworks/smtp",
          :description => "Ip Address/hostname of SMTP server (default is smtp.gmail.com)",
          :type => 'string'

attribute "hopsworks/smtp_port",
          :description => "Port of SMTP server (default is 587)",
          :type => 'string'

attribute "hopsworks/smtp_ssl_port",
          :description => "SSL port of SMTP server (default is 465)",
          :type => 'string'

attribute "hopsworks/alert_email_addrs",
          :description => "Comma-separated list of email addresses that will receive emails for alerts in Hopsworks",
          :type => 'string'

attribute "hopsworks/admin/user",
          :description => "Username for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "hopsworks/admin/password",
          :description => "Password for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "hopsworks/dir",
          :description => "Installation directory for the glassfish binaries",
          :type => 'string'

attribute "hopsworks/user",
          :description => "Hopsworks/glassfish username to run service as",
          :type => 'string'

attribute "hopsworks/group",
          :description => "Hopsworks/glassfish group to run service as",
          :type => 'string'

attribute "glassfish/user-home",
          :description => "Home directory of glassfish user",
          :type => 'string'

attribute "hopsworks/domains_dir",
          :description => "Installation directory for the glassfish domains",
          :type => 'string'

attribute "hopsworks/nodes_dir",
          :description => "Installation directory for the glassfish nodes",
          :type => 'string'

attribute "hopsworks/domain_truststore",
          :description => "Name of the glassfish truststore for this domain.",
          :type => 'string'

attribute "hopsworks/domain_truststore_path",
          :description => "Path where domain_truststore is stored",
          :type => 'string'

attribute "hopsworks/master/password",
          :description => "Web Application Server master password",
          :type => 'string'

attribute "download_url",
          :description => "URL for downloading binaries",
          :type => 'string'


attribute "hopsworks/cert/user_cert_valid_days",
           :description => "How long in days will the user certs be valid. Default 12 days.",
           :type => 'string'


attribute "hopsworks/cert/password",
           :description => "password to glassfish certs",
           :type => 'string'

attribute "hopsworks/pki/root/name",
          :description => "X.509 Subject name for Root CA",
          :type => 'string'

attribute "hopsworks/pki/root/duration",
          :description => "Validity period for Root CA. Valid suffixes: s, m, h, d",
          :type => 'string'

attribute "hopsworks/pki/intermediate/name",
          :description => "X.509 Subject name for Intermediate CA",
          :type => 'string'

attribute "hopsworks/pki/intermediate/duration",
          :description => "Validity period for Intermediate CA. Valid suffixes: s, m, h, d",
          :type => 'string'

attribute "hopsworks/pki/intermediate/extra_san_for_username",
          :description => "Configurable extra DNS SAN for system users such as hdfs. Check attributes/default.rb for the correct format",
          :type => 'string'

attribute "hopsworks/pki/kubernetes/name",
          :description => "X.509 Subject name for Kubernetes CA",
          :type => 'string'

attribute "hopsworks/pki/kubernetes/duration",
          :description => "Validity period for Kubernetes CA. Valid suffixes: s, m, h, d",
          :type => 'string'

attribute "hopsworks/cert/cn",
          :description => "Certificate Name",
          :type => 'string'

attribute "hopsworks/cert/o",
          :description => "organization name",
          :type => 'string'

attribute "hopsworks/cert/ou",
          :description => "Organization unit",
          :type => 'string'

attribute "hopsworks/cert/l",
          :description => "Location",
          :type => 'string'

attribute "hopsworks/cert/s",
          :description => "City",
          :type => 'string'

attribute "hopsworks/cert/c",
          :description => "Country (2 letters)",
          :type => 'string'

attribute "glassfish/version",
          :description => "glassfish/version",
          :type => 'string'

attribute "glassfish/user",
          :description => "Install and run the glassfish server as this username",
          :type => 'string'

attribute "glassfish/group",
          :description => "glassfish/group",
          :type => 'string'

attribute "hopsworks/https/port",
          :description => "Port that webserver will listen on",
          :type => 'string'

attribute "hopsworks/https/key_url",
          :description => "Location from where to download the user provided key for the HTTPS listener",
          :type => 'string'

attribute "hopsworks/https/cert_url",
          :description => "Location from where to download the user provided certificate for the HTTPS listener",
          :type => 'string'

attribute "hopsworks/https/intermediate_ca_url",
          :description => "Location from where to download the user provided intermediate CA for the HTTPS listener, can be empty to omit",
          :type => 'string'

attribute "hopsworks/https/ca_url",
          :description => "Location from where to download the user provided CA for the HTTPS listener",
          :type => 'string'

attribute "hopsworks/internal/port",
          :description => "Port that the webserver will listen on for internal calls",
          :type => 'string'

attribute "hopsworks/internal/enable_http",
          :description => "Enable http. 'false' (default)",
          :type => 'string'

attribute "hopsworks/ha/loadbalancer_port",
          :description => "Load balancer port. '1080' (default)",
          :type => 'string'

attribute "hopsworks/max_mem",
          :description => "glassfish/max_mem",
          :type => 'string'

attribute "hopsworks/min_mem",
          :description => "glassfish/min_mem",
          :type => 'string'

attribute "hopsworks/max_stack_size",
          :description => "glassfish/max_stack_size",
          :type => 'string'

attribute "hopsworks/http_logs/enabled",
          :description => "Enable logging of HTTP requests and dump to HDFS",
          :type => 'string'

attribute "hopsworks/max_perm_size",
          :description => "glassfish/max_perm_size",
          :type => 'string'

attribute "hopsworks/reinstall",
          :description => "Enter 'true' if this is a reinstallation",
          :type => 'string'

attribute "hopsworks/download_url",
          :description => "Base URL to download Hopsworks artifacts e.g. DOWNLOAD_URL/hopsworks.war",
          :type => 'string'

attribute "hopsworks/war_url",
          :description => "Url for the hopsworks war file",
          :type => 'string'

attribute "hopsworks/ear_url",
          :description => "Url for the hopsworks ear file",
          :type => 'string'

attribute "hopsworks/logsize",
          :description => "Size of Glassfish log file for Hopsworks",
          :type => 'string'

attribute "hopsworks/ca_url",
          :description => "Url for the hopsworks certificate authority war file",
          :type => 'string'

attribute "hopsworks/yarn_default_quota_mins",
          :description => "Default number of CPU mins availble per project",
          :type => 'string'

attribute "hopsworks/hdfs_default_quota",
          :description => "Default amount in bytes of available storage per project",
          :type => 'string'

attribute "hopsworks/hive_default_quota",
          :description => "Default amount in bytes of available storage per project",
          :type => 'string'

attribute "hopsworks/featurestore_default_quota",
          :description => "Default amount in bytes of available storage for the featurestore service per project",
          :type => 'string'

attribute "hopsworks/featurestore_online",
          :description => "Enable the creation of NDB databases for the online featurestore. (Default: true)",
          :type => 'string'

attribute "hopsworks/max_num_proj_per_user",
          :description => "Maximum number of projects that can be created by each user",
          :type => 'string'

attribute "hopsworks/reserved_project_names",
          :description => "Comma-separated list of Project names a user user is not allowed to use",
          :type => 'string'

attribute "hopsworks/encryption_password",
          :description => "Default master encryption password for storing secrets.",
          :type => 'string'

attribute "hopsworks/file_preview_image_size",
          :description => "Maximum size in bytes of an image that can be previewed in DataSets",
          :type => 'string'

attribute "hopsworks/file_preview_txt_size",
          :description => "Maximum size in lines of file that can be previewed in DataSets",
          :type => 'string'

attribute "hopsworks/download_allowed",
          :description => "Whether users should be allowed to download files from datasets. Default value is true.",
          :type => 'string'

attribute "hopsworks/anaconda_enabled",
          :description => "Default is 'true'. Set to 'false' to disable anaconda.",
          :type => 'string'

attribute "hopsworks/nonconda_hosts",
          :description => "Comma separated list of IPs on which you should not enable conda.",
          :type => 'string'

attribute "hopsworks/staging_dir",
          :description => "Default is a 'domains/domain1/scratch'. Override to use a path on a disk volume with plenty of available space.",
          :type => 'string'

attribute "hopsworks/version",
          :description => "The version of ear/web/ca to download",
          :type => 'string'

attribute "hopsworks/hopsworks_public_host",
					:description => "Hopsworks public hostname",
					:type => 'string'

attribute "hopsworks/hopsworks_rest_log_level",
					:description => "Default 'TEST' set to 'PROD' to only get user error messages. Hopsworks rest log level",
					:type => 'string'

attribute "vagrant",
          :description => "'true' to rewrite /etc/hosts, 'false' to disable vagrant /etc/hosts",
          :type => 'string'

attribute "services/enabled",
          :description => "Default 'false'. Set to 'true' to enable daemon services, so that they are started on a host restart.",
          :type => "string"

attribute "install/dir",
          :description => "Default ''. Set to a base directory under which all hops services will be installed.",
          :type => "string"

attribute "install/user",
          :description => "User to install the services as",
          :type => "string"

attribute "install/ssl",
          :description => "Is SSL turned on for all services?",
          :type => "string"

attribute "install/addhost",
          :description => "Indicates that this host will be added to an existing Hops cluster.",
          :type => "string"

attribute "hopsworks/monitor_max_status_poll_try",
          :description => "Default number of time the job monitor fail at polling the job status before to consider the job as failed",
          :type => 'string'

attribute "hopsworks/db",
          :description => "Default hopsworks database",
          :type => 'string'

attribute "hopsworks/mysql/user",
          :description => "Hopsworks MySQL username",
          :type => 'string'

attribute "hopsworks/mysql/password",
          :description => "Hopsworks MySQL password",
          :type => 'string'

attribute "hopsworks/check_nodemanager_status",
          :description => "Boolean value to check nodemanagers status before starting a job",
          :type => 'string'


##
##
## Hive
##
##

attribute "hopsworks/hive2/scratch_dir_delay",
          :description => "How much to wait before deleting the directory",
          :type => "string"

attribute "hopsworks/hive2/scratch_dir_cleaner_interval",
          :description => "Interval between scratch dir cleaner runs",
          :type => "string"



##
##
## Serving
##
##

attribute "serving/base_dir",
          :description => "base directory for temporary directories for serving servers",
          :type => 'string'

attribute "serving/pool_size",
          :description => "size of the connection pool for serving inference requests to model serving servers",
          :type => 'string'

attribute "serving/max_route_connections",
          :description => "max number of connections to serve requests to a unique route for model serving servers",
          :type => 'string'

##
##
## Jupyter
##
##

attribute "jupyter/shutdown_timer_interval",
          :description => "notebook cleaner interval for shutting down expired notebooks",
          :type => 'string'

attribute "jupyter/ws_ping_interval",
          :description => "Ping frequency for the jupyter websocket",
          :type => 'string'


attribute "hopsworks/org_name",
          :description => "Organization name for this hopsworks cluster",
          :type => 'string'

attribute "hopsworks/org_domain",
          :description => "Domain name for this organization",
          :type => 'string'

attribute "hopsworks/org_city",
          :description => "City  for this organization",
          :type => 'string'

attribute "hopsworks/org_country_code",
          :description => "2-Letter Country code for this organization ('us', 'se', 'uk', etc)",
          :type => 'string'
# Hops site

attribute "hopsworks/support_email_addr",
          :description => "Email address to contact for email registration problems",
          :type => 'string'

#
# LDAP
#

attribute "ldap/enabled",
          :description => "Enable ldap auth. 'false' (default)",
          :type => 'string'

attribute "ldap/group_mapping",
          :description => "LDAP group to hopsworks group mappings. Format: (groupA-> HOPS_USER,HOPS_ADMIN;groupB->HOPS_USER)",
          :type => 'string'

attribute "ldap/user_id",
          :description => "The login field used by ldap. 'uid' (default)",
          :type => 'string'

attribute "ldap/user_givenName",
          :description => "Given name field of ldap 'givenName' (default)",
          :type => 'string'

attribute "ldap/user_surname",
          :description => "Surname field of ldap. 'sn' (default)",
          :type => 'string'

attribute "ldap/user_email",
          :description => "Email field of ldap. 'mail' (default)",
          :type => 'string'

attribute "ldap/user_search_filter",
          :description => "LDAP user search filter. 'uid=%s' (default)",
          :type => 'string'

attribute "ldap/group_search_filter",
          :description => "LDAP group search filter. 'member=%d' (default)",
          :type => 'string'

attribute "ldap/krb_search_filter",
          :description => "LDAP user krb search filter. 'krbPrincipalName=%s' (default)",
          :type => 'string'

attribute "ldap/attr_binary",
          :description => "LDAP global Unique Identity Code of the object attribute. 'java.naming.ldap.attributes.binary' (default)",
          :type => 'string'

attribute "ldap/group_target",
          :description => "LDAP search result group target 'cn' (default)",
          :type => 'string'

attribute "ldap/dyn_group_target",
          :description => "LDAP search result dynamic group target 'memberOf' (default)",
          :type => 'string'

attribute "ldap/user_dn",
          :description => "LDAP baseDN. '' (default)",
          :type => 'string'

attribute "ldap/group_dn",
          :description => "LDAP groupDN. '' (default)",
          :type => 'string'

attribute "ldap/account_status",
          :description => "Hopsworks account status given for new LDAP user. '1' verified account (default)",
          :type => 'string'
#LDAP External JNDI Resource
attribute "ldap/provider_url",
          :description => "LDAP provider url. ",
          :type => 'string'

attribute "ldap/jndilookupname",
          :description => "LDAP jndi lookup name. ",
          :type => 'string'

attribute "ldap/attr_binary_val",
          :description => "LDAP global Unique Identity Code of the user object. 'entryUUID' (default)",
          :type => 'string'

attribute "ldap/security_auth",
          :description => "LDAP security auth type. 'none' (default) possible values ('none', 'simple', 'sasl_mech')",
          :type => 'string'

attribute "ldap/security_principal",
          :description => "LDAP security principal. '' (default)",
          :type => 'string'

attribute "ldap/security_credentials",
          :description => "LDAP security credentials. '' (default)",
          :type => 'string'

attribute "ldap/referral",
          :description => "LDAP used to redirect a client's request to another server . 'ignore' (default) possible values ('ignore', 'follow', 'throw')",
          :type => 'string'

attribute "ldap/additional_props",
          :description => "LDAP additional properties. '' (default)",
          :type => 'string'

attribute "ldap/group_mapping_sync_enabled",
          :description => "Enable background LDAP group mapping sync. false (default)",
          :type => 'string'

attribute "ldap/group_mapping_sync_interval",
          :description => "LDAP group mapping sync interval in hours. 0 (default)",
          :type => 'string'

attribute "ldap/groups_search_filter",
          :description => "Filter to use when looking up for groups in configured LDAP server. Default: (&(objectCategory=group)(cn=%c))",
          :type => 'string'

#
# Kerberos
#

attribute "kerberos/enabled",
          :description => "Enable Kerberos auth. 'false' (default)",
          :type => 'string'

attribute "kerberos/kerberos_fqdn",
          :description => "Kerberos fully qualified domain name. '' (default)",
          :type => 'string'

attribute "kerberos/spnego_principal",
          :description => "Spnego principal . 'HTTP/server.example.com' (default)",
          :type => 'string'

attribute "kerberos/spnego_keytab_file",
          :description => "Spnego principal keytab file path. '/etc/security/keytabs/service.keytab' (default)",
          :type => 'string'

attribute "kerberos/krb_conf_path",
          :description => "Kerberos conf path. '/etc/krb5.conf' (default)",
          :type => 'string'

attribute "kerberos/spnego_server_conf",
          :description => "Spnego server extra conf. 'storeKey=true\nisInitiator=false' (default)",
          :type => 'string'

attribute "kerberos/krb_server_key_tab_path",
          :description => "Spnego server keyTab file location. '/etc/security/keytabs/service.keytab' (default)",
          :type => 'string'

attribute "kerberos/krb_server_key_tab_name",
          :description => "Spnego server keyTab file name. 'service.keytab' (default)",
          :type => 'string'

# OAuth2
attribute "oauth/enabled",
          :description => "Enable OAuth. 'false' (default)",
          :type => 'string'
attribute "oauth/redirect_uri",
          :description => "OAuth redirect uri. 'hopsworks/callback' (default)",
          :type => 'string'
attribute "oauth/logout_redirect_uri",
          :description => "OAuth logout redirect uri. 'hopsworks/' (default)",
          :type => 'string'
attribute "oauth/account_status",
          :description => "Hopsworks account status given for new OAuth user. '1' verified account (default)",
          :type => 'string'
attribute "oauth/group_mapping",
          :description => "OAuth group to hopsworks group mappings. Format: (groupA-> HOPS_USER,HOPS_ADMIN;groupB->HOPS_USER)",
          :type => 'string'

attribute "remote_auth/need_consent",
          :description => "Remote user need to consent on first login. 'true' (default)",
          :type => 'string'

attribute "hopsworks/disable_password_login",
          :description => "Disable password login. 'false' (default)",
          :type => 'string'
attribute "hopsworks/disable_registration",
          :description => "Disable registration. 'false' (default)",
          :type => 'string'

### Kapacitor

attribute "kapacitor/notify/email",
          :description => "Email address. Recommended to use a gmail account",
          :type => 'string'

attribute "kapacitor/slack_enabled",
          :description => "Send notifications to slack",
          :type => 'string'

attribute "kapacitor/slack_url",
          :description => "Slack url hook.",
          :type => 'string'

attribute "kapacitor/slack_channel",
          :description => "Slack channel name",
          :type => 'string'


### Kafka

attribute "hopsworks/kafka_max_num_topics",
          :description => "Default max number of kafka topics per project",
          :type => 'string'

attribute "hopsworks/kafka_num_replicas",
          :description => "Default number of replicas for Kafka Topics.",
          :type => 'string'

attribute "hopsworks/kafka_num_partitions",
          :description => "Default number of partitions for Kafka Topics.",
          :type => 'string'


### RStudio

attribute "rstudio/enabled",
          :description => "Set to 'true' to enable RStudio in Hopsworks. Default 'false'.",
          :type => 'string'

### PyPi

attribute "hopsworks/pypi_rest_endpoint",
          :description => "Url to PyPi REST API to query package information",
          :type => 'string'

attribute "hopsworks/pypi_simple_endpoint",
          :description => "Url to PyPi simple endpoint",
          :type => 'string'

attribute "hopsworks/pypi_indexer_timer_interval",
          :description => "How often to run the PyPi Indexer",
          :type => 'string'

attribute "hopsworks/pypi_indexer_timer_enabled",
          :description => "Whether to enable the PyPi Indexer",
          :type => 'string'

attribute "hopsworks/python_library_updates_monitor_interval",
          :description => "Interval for monitoring new releases for libraries",
          :type => 'string'

### TensorBoard

attribute "hopsworks/tensorboard_max_last_accessed",
          :description => "Time in milliseconds to wait after a TensorBoard is requested before considering it old (and should be killed)",
          :type => 'string'

### JWT

attribute "hopsworks/jwt/signature_algorithm",
          :description => "Default signature algorithm for jwt. (default HS512)",
          :type => 'string'

attribute "hopsworks/jwt/lifetime_ms",
          :description => "Default lifetime in ms for jwt expiration. (default 86400000ms - 24h)",
          :type => 'string'

attribute "hopsworks/jwt/exp_leeway_sec",
          :description => "Default expiration leeway in sec. (default 900)",
          :type => 'string'

attribute "hopsworks/jwt/signing_key_name",
          :description => "Default signing key name. (default apiKey)",
          :type => 'string'

attribute "hopsworks/jwt/issuer",
          :description => "JWT issuer identifier. (default hopsworks@logicalclocks.com)",
          :type => 'string'

attribute "hopsworks/jwt/service_lifetime_ms",
          :description => "Default lifetime in ms for service jwt expiration. (default 604800000)",
          :type => 'string'

attribute "hopsworks/jwt/service_exp_leeway_sec",
          :description => "Default expiration leeway in sec for service jwt",
          :type => 'string'

### Feature Store
attribute "hopsworks/featurestore_default_storage_format",
          :description => "Default storage format for the hive database of the feature stores (ORC/PARQUET)",
          :type => 'string'

# Glassfish Http Configuration
attribute "glassfish/http/keep_alive_timeout",
          :description => "Glassfish http listeners Keep alive timeout seconds",
          :type => 'string'

# Glassfish Timer Configuration
attribute "glassfish/reschedule_failed_timer",
        :description => "Whether failed timers should be rescheduled to prevent them being expunged (default true)",
        :type => 'string'

# Glassfish timeout, in seconds, for requests. A value of -1 will disable it.
attribute "glassfish/http/request-timeout-seconds",
        :description => "timeout, in seconds, for requests. A value of -1 will disable it. (default 3600)",
        :type => 'string'

# Online featurestore jdbc connection details
attribute "featurestore/jdbc_url",
          :description => "Url for JDBC Connection to the the Online FeatureStore",
          :type => 'string'

attribute "featurestore/job_activity_timer",
          :description => "How often to run the timer to backfill jobs for feature groups and training datasets - default 5 minutes",
          :type => 'string'

# hops-util-py
attribute "hopsworks/requests_verify",
          :description => "Whether to verify http(s) requests in hops-util-py",
          :type => 'string'

attribute "hopsworks/provenance/type",
          :description => "MIN provenance - community edition. FULL provenance - enterprise",
          :type => 'string'

attribute "hopsworks/provenance/archive/batch_size",
          :description => "Provenance cleaning size per round. Number of cleaned indices(per project)",
          :type => 'string'

attribute "hopsworks/provenance/archive/delay",
          :description => "Provenance archive delay. How long to delay cleanup of document after delete (currently only fo FULL provenance)",
          :type => 'string'

attribute "hopsworks/provenance/cleaner/period",
          :description => "Provenance cleaning delay. Define in seconds the period between two provenance cleaner timeouts - default 1h",
          :type => 'string'

# Audit log
attribute "hopsworks/audit_log_dir",
          :description => "Audit log dir. '/srv/hops/domains/domain1/logs/audit' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_file_format",
          :description => "Audit log file format. 'server_audit_log%g.log' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_size_limit",
          :description => "Audit log size per file. '3.3.00000' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_count",
          :description => "Audit file count. '10' (default)",
          :type => 'string'
attribute "hopsworks/audit_log_file_type",
          :description => "Audit log file type. 'Text' (default)",
          :type => 'string'

# Hopsworks HDFS storage policies
# accepted hopsworks storage policy files: CLOUD, DB, HOT
attribute "hopsworks/hdfs/storage_policy/base",
          :description => "Set the DIR_ROOT (/Projects) storage policy. Default is DB. Accepted values: CLOUD/DB/HOT",
          :type => 'string'
attribute "hopsworks/hdfs/storage_policy/log",
          :description => "Set the project LOG_DIR storage policy. Default is HOT. Accepted values: CLOUD/DB/HOT",
          :type => 'string'

# Expat
attribute "hopsworks/expat_url",
          :description => "Url to download expat from",
          :type => 'string'

#TensorBoard'
attribute "tensorboard/max/reload/threads",
          :description => "The max number of threads that TensorBoard can use to reload runs. Not relevant for db read-only mode. Each thread reloads one run at a time.",
          :type => "string"

#Azure CA cert download url
attribute "hopsworks/azure-ca-cert/download-url",
          :description => "Azure CA cert download url. 'https://cacerts.digicert.com/DigiCertGlobalRootG2.crt' (default)",
          :type => "string"

attribute "hopsworks/livy_startup_timeout",
          :description => "timeout for livy sessions startup",
          :type => "string"
# Docker job
attribute "hopsworks/docker-job/docker_job_mounts_list",
					:description => "Host path directories that can be mounted with Docker jobs",
					:type => "string"

attribute "hopsworks/docker-job/docker_job_mounts_allowed",
					:description => "Enable or disable mounting host paths with Docker jobs",
					:type => "string"

attribute "hopsworks/docker-job/docker_job_uid_strict",
					:description => "Enable or disable strict mode for uig/gid of docker jobs. In strict mode, users cannot set the uid/gid of the job.",
					:type => "string"

attribute "hopsworks/job/executions_per_job_limit",
					:description => "Maximum number of executions allowed per job in a project.",
					:type => "string"

attribute "hopsworks/job/executions_cleaner_batch_size",
					:description => "The maximum number of executions to be deleted per job per timer trigger.",
					:type => "string"

attribute "hopsworks/job/executions_cleaner_interval_ms",
					:description => "How often the job executions cleaner is triggered.",
					:type => "string"

attribute "hopsworks/enable_user_search",
          :description => "Whether to enable user search or not",
          :type => 'string'
      
attribute "hopsworks/kubernetes/api_max_attempts",
          :description => "Maximum number of Kubernetes client retries before failing the request. Default: 12",
          :type => 'string'

attribute "hopsworks/reject_remote_user_no_group",
          :description => "Whether to reject oauth user creation if the user does not map with any group",
          :type => 'string'

attribute "hopsworks/managed_cloud_redirect_uri",
          :description => "redirect uri for managed group setup",
          :type => 'string'

attribute "hopsworks/debug",
          :description => "Start glassfish server in debug mode. Default 'false'",
          :type => 'string'

attribute "hopsworks/kubernetes/skip_namespace_creation",
          :description => "Skip creation and deletion of kubernetes namespace(s) in Hopsworks. If enabled, users will have to manage their project namespaces before creating the project. Kubernetes only allow lowercase characters, numbers, and dash (-) as a valid name, so you should map the project name to match this pattern by replacing all non valid characters to a dash (-). Default 'false'",
          :type => 'string'

attribute "hopsworks/quotas/online_enabled_featuregroups",
          :description => "Maximum number of online enabled feature groups per project. Default: -1 (disabled)",
          :type => 'string'

attribute "hopsworks/quotas/online_disabled_featuregroups",
          :description => "Maximum number of online disabled feature groups per project. Default: -1 (disabled)",
          :type => 'string'

attribute "hopsworks/quotas/training_datasets",
          :description => "Maximum number of training datasets per project. Default: -1 (disabled)",
          :type => 'string'

attribute "hopsworks/quotas/total_model_deployments",
          :description => "Maximum number of total model deployments per project. Default: -1 (disabled)",
          :type => 'string'

attribute "hopsworks/quotas/running_model_deployments",
          :description => "Maximum number of concurrently running model deployments per project. Default: -1 (disabled)",
          :type => 'string'

attribute "hopsworks/quotas/max_parallel_executions",
          :description => "Maximum number of parallel Jobs executions per project. Default: -1 (disabled)",
          :type => 'string'

attribute "hopsworks/docker/cgroup_monitor_interval",
					:description => "Time to periodically monitor cgroup values if enabled",
					:type => 'string'

attribute "hopsworks/kube/kube_taints_monitor_interval",
					:description => "Time to periodically update tainted nodes in the database",
					:type => 'string'

attribute "hopsworks/enable_data_science_profile",
          :description => "Whether to enable the data science profile or not. This profile includes Model Registry and Serving.",
          :type => 'string'

attribute "hopsworks/enable_read_only_git_repositories",
          :description => "Whether or not to make git repositories read only (Default: true)",
          :type => 'string'

# Glassfish managed executor pools
attribute "hopsworks/managed_executor_pools/jupyter/threadpriority",
          :description => "Jupyter Managed Executor Pool thread priority",
          :type => 'string'

attribute "hopsworks/managed_executor_pools/jupyter/corepoolsize",
          :description => "Jupyter Managed Executor Pool core size",
          :type => 'string'

attribute "hopsworks/managed_executor_pools/jupyter/maximumpoolsize",
          :description => "Jupyter Managed Executor Pool maximum size",
          :type => 'string'

attribute "hopsworks/managed_executor_pools/jupyter/taskqueuecapacity",
          :description => "Jupyter Managed Executor Pool queue size",
          :type => 'string'

# Storage connectors

attribute "hopsworks/enable_snowflake_storage_connectors",
          :description => "Whether to enable Snowflake storage connectors or not",
          :type => 'string'

attribute "hopsworks/enable_redshift_storage_connectors",
          :description => "Whether to enable Redshift storage connectors or not",
          :type => 'string'

attribute "hopsworks/enable_adls_storage_connectors",
          :description => "Whether to enable ADLS storage connectors or not",
          :type => 'string'

attribute "hopsworks/enable_kafka_storage_connectors",
          :description => "Whether to enable Kafka storage connectors or not",
          :type => 'string'

attribute "hopsworks/enable_gcs_storage_connectors",
          :description => "Whether to enable GCS storage connectors or not",
          :type => 'string'

attribute "hopsworks/enable_bigquery_storage_connectors",
          :description => "Whether to enable BigQuery storage connectors or not",
          :type => 'string'

attribute "hopsworks/enable_bring_your_own_kafka",
          :description => "Whether to enable bring your own kafka or not",
          :type => 'string'

attribute "hopsworks/enable_jupyter_python_kernel_non_kubernetes",
          :description => "Show the Python kernel in Jupyter configuration page and Jupyter interface. Only takes effect if Kubernetes is not installed. Default: false",
          :type => 'string'

attribute "hopsworks/max_allowed_long_running_http_requests",
          :description => "Maximum number of long running http requests allowed. Default: 50",
          :type => 'string'

attribute "hopsworks/enable_flyingduck",
          :description => "Whether to enable flyingduck or not. Default: false",
          :type => 'string'

attribute "hopsworks/loadbalancer_external_domain",
          :description => "URL of the Hopsworks external load balancer. Default: ''",
          :type => 'string'

attribute "hopsworks/jupyter/remote_fs_driver",
	  :description => "Driver to interact with HOPSFS. Can be hdfscontentsmanager or hopsfsmount. Default is hdfscontentsmanager.",
	  :type => "string"

attribute "judge/port",
          :description => "Port where the Judge service will be listening on. Default: 5001",
          :type => 'string'