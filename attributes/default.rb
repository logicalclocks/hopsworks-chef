include_attribute "kagent"
include_attribute "ndb"
include_attribute "hadoop_spark"
include_attribute "flink"
include_attribute "elastic"
include_attribute "zeppelin"
include_attribute "glassfish"
include_attribute "kkafka"
include_attribute "kzookeeper"

default["hopsworks"]["version"]                  = "0.1.0"

default["glassfish"]["variant"]                  = "payara"
default["hopsworks"]["user"]                     = node["install"]["user"].empty? ? "glassfish" : node["install"]["user"]
default["glassfish"]["user"]                     = node["hopsworks"]["user"]
default["hopsworks"]["group"]                    = node["install"]["user"].empty? ? "glassfish" : node["install"]["user"]
default["glassfish"]["group"]                    = node["hopsworks"]["group"]
default["hopsworks"]["admin"]["port"]               = 4848
default["hopsworks"]["port"]                     = "8080"
default["glassfish"]["admin"]["port"]               = node["hopsworks"]["admin"]["port"]
default["glassfish"]["port"]                     = node["hopsworks"]["port"].to_i
default["glassfish"]["version"]                  = '4.1.1.171.0.1'

default["hopsworks"]["dir"]                      = node["install"]["dir"].empty? ? "/usr/local" : node["install"]["dir"]
default["glassfish"]["install_dir"]              = node["hopsworks"]["dir"]
default["glassfish"]["base_dir"]                 = node["glassfish"]["install_dir"] + "/glassfish"
default["hopsworks"]["domains_dir"]              = node["install"]["dir"].empty? ? node["hopsworks"]["dir"] + "/domains" : node["install"]["dir"] + "/domains"
default["glassfish"]["domains_dir"]              = node["hopsworks"]["domains_dir"]


default["hopsworks"]["certs_dir"]                = node["install"]["dir"].empty? ? node["hopsworks"]["dir"] + "/certs-dir" : node["install"]["dir"] + "/certs-dir"


default["hopsworks"]["max_mem"]                  = "3000"
default["glassfish"]["max_mem"]                  = node["hopsworks"]["max_mem"].to_i
default["hopsworks"]["min_mem"]                  = "1024"
default["glassfish"]["min_mem"]                  = node["hopsworks"]["min_mem"].to_i
default["hopsworks"]["max_stack_size"]           = "4000"
default["glassfish"]["max_stack_size"]           = node["hopsworks"]["max_stack_size"].to_i
default["hopsworks"]["max_perm_size"]            = "1500"
default["glassfish"]["max_perm_size"]            = node["hopsworks"]["max_perm_size"].to_i
default["hopsworks"]["max_stack_size"]           = "1500"
default["glassfish"]["max_stack_size"]           = node["hopsworks"]["max_stack_size"].to_i


default["glassfish"]["package_url"]              = node["download_url"] + "/payara-#{node["glassfish"]["version"]}.zip"
default["hopsworks"]["cauth_url"]                = "#{node["download_url"]}/otp-auth-2.0.jar"
default["hopsworks"]["war_url"]                  = "#{node["download_url"]}/hopsworks/#{node["hopsworks"]["version"]}/hopsworks.war"
default["hopsworks"]["ca_url"]                   = "#{node["download_url"]}/hopsworks/#{node["hopsworks"]["version"]}/hopsworks-ca.war"
default["hopsworks"]["ear_url"]                  = "#{node["download_url"]}/hopsworks/#{node["hopsworks"]["version"]}/hopsworks-ear.ear"
default["hopsworks"]["ca_url"]                   = "#{node["download_url"]}/hopsworks/#{node["hopsworks"]["version"]}/hopsworks-ca.war"


default["hopsworks"]["admin"]["user"]               = "adminuser"
default["hopsworks"]["admin"]["password"]           = "adminpw"
default["glassfish"]["cert"]["password"]            = "#{node["hopsworks"]["admin"]["password"]}"
default["hopsworks"]["twofactor_auth"]           = "false"
default["hopsworks"]["twofactor_exclude_groups"] = "AGENT" #semicolon separated list of roles

default["hopsworks"]["mysql_connector_url"]      = "http://snurran.sics.se/hops/mysql-connector-java-5.1.29-bin.jar"

default["hopsworks"]["cert"]["cn"]                  = "sics.se"
default["hopsworks"]["cert"]["o"]                   = "swedish ict"
default["hopsworks"]["cert"]["ou"]                  = "sics"
default["hopsworks"]["cert"]["l"]                   = "kista"
default["hopsworks"]["cert"]["s"]                   = "stockholm"
default["hopsworks"]["cert"]["c"]                   = "se"

default["hopsworks"]["cert"]["password"]            = "changeit"
default["hopsworks"]["master"]["password"]          = "adminpw"

default["hopsworks"]["public_ips"]               = ['10.0.2.15']
default["hopsworks"]["private_ips"]              = ['10.0.2.15']

default["kagent"]["enabled"]                     = "false"

default["hopsworks"]["smtp"]                     = node["smtp"]["host"]
default["hopsworks"]["smtp_port"]                = node["smtp"]["port"]
default["hopsworks"]["smtp_ssl_port"]            = node["smtp"]["ssl_port"]
default["hopsworks"]["email"]                    = node["smtp"]["email"]
default["hopsworks"]["email_password"]           = node["smtp"]["email_password"]
default["hopsworks"]["gmail"]["placeholder"]        = "http://snurran.sics.se/hops/hopsworks.email"

# #quotas
default["hopsworks"]["yarn_default_quota_mins"]  = "10000"
default["hopsworks"]["hdfs_default_quota_mbs"]   = "200000"
default["hopsworks"]["max_num_proj_per_user"]    = "10"

# file preview
default["hopsworks"]["file_preview_image_size"]  = "10000000"
default["hopsworks"]["file_preview_txt_size"]    = "100"

default["hops"]["user_envs"]                     = "false"

default["hopsworks"]["systemd"]                  = "true"


default["hopsworks"]["kafka_num_replicas"]       = "1"
default["hopsworks"]["kafka_num_partitions"]     = "1"

default["glassfish"]["ciphersuite"]				= "+TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,+TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,+TLS_RSA_WITH_AES_128_CBC_SHA256,+TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256,+TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256,+TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,+TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,+TLS_RSA_WITH_AES_128_CBC_SHA,+TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA,+TLS_ECDH_RSA_WITH_AES_128_CBC_SHA,+TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA,+TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA,+TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA,+TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA"
											
#
# Dela
#

default["hopsworks"]["dela"]["domain"]                 = "bbc1.sics.se"
default["hopsworks"]["dela"]["certifcate"]             = "DummyCert25100"
default["hopsworks"]["dela"]["hops_site_base_uri"]     = "http://bbc1.sics.se:25100/hops-site/webresources"
default["hopsworks"]["dela"]["public_search_endpoint"] =  "hopsworks/api/elastic/publicdatasets/"

default["hopsworks"]["max_gpu_request_size"]        = 1
default["hopsworks"]["max_cpu_request_size"]        = 1

default["hopsworks"]["anaconda_enabled"]            = node["kagent"]["conda_enabled"]


#
# Jupyter
#
default["jupyter"]["base_dir"]                      = node["install"]["dir"].empty? ? node["hopsworks"]["dir"] + "/jupyter" : node["install"]["dir"] + "/jupyter"
default["jupyter"]["user"]                          = node["install"]["user"].empty? ? "jupyter" : node["install"]["user"]
default["jupyter"]["group"]                         = node["install"]["user"].empty? ? "jupyter" : node["install"]["user"]
