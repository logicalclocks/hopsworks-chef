username="adminuser"
password="adminpw"
domain_name="domain1"
domains_dir = '/usr/local/glassfish/glassfish/domains'
admin_port = 4848
mysql_host = private_recipe_ip("ndb","mysqld")
mysql_user = "kthfs"
mysql_password = "kthfs"


node.override = {
  'java' => {
    'install_flavor' => 'oracle',
    'jdk_version' => 7,
    'oracle' => {
      'accept_oracle_download_terms' => true
    }
  },
  'glassfish' => {
    'version' => '4.1',
    'base_dir' => '/usr/local/glassfish',
    'domains_dir' => domains_dir,
    'domains' => {
      domain_name => {
        'config' => {
          'min_memory' => 1024,
          'max_memory' => 1024,
          'max_perm_size' => 256,
          'port' => 8080,
          'admin_port' => admin_port,
          'username' => username,
          'password' => password,
          'master_password' => 'mykeystorepassword',
          'remote_access' => false,
          'jvm_options' => ['-DMYAPP_CONFIG_DIR=/usr/local/myapp/config', '-Dcom.sun.enterprise.tools.admingui.NO_NETWORK=true'],
          'secure' => false
        },
        'extra_libraries' => {
          'jdbcdriver' => {
            'type' => 'common',
            'url' => 'http://snurran.sics.se/hops/mysql-connector-java-5.1.29-bin.jar'
          }
        },
        'threadpools' => {
          'thread-pool-1' => {
            'maxthreadpoolsize' => 200,
            'minthreadpoolsize' => 5,
            'idletimeout' => 900,
            'maxqueuesize' => 4096
          },
          'http-thread-pool' => {
            'maxthreadpoolsize' => 200,
            'minthreadpoolsize' => 5,
            'idletimeout' => 900,
            'maxqueuesize' => 4096
          },
          'admin-pool' => {
            'maxthreadpoolsize' => 50,
            'minthreadpoolsize' => 5,
            'maxqueuesize' => 256
          }
        },
        'iiop_listeners' => {
          'orb-listener-1' => {
            'enabled' => true,
            'iiopport' => 1072,
            'securityenabled' => false
          }
        },
        'jdbc_connection_pools' => {
          'hopsworksPool' => {
            'config' => {
              'datasourceclassname' => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
              'restype' => 'javax.sql.DataSource',
              'isconnectvalidatereq' => 'true',
              'validationmethod' => 'auto-commit',
              'ping' => 'true',
              'description' => 'Hopsworks Connection Pool',
              'properties' => {
                'Url' => "jdbc:mysql://#{mysql_host}:3306/",
                'User' => mysql_user,
                'Password' => mysql_password
              }
            },
            'resources' => {
              'jdbc/hopsworks' => {
                'description' => 'Resource for Hopsworks Pool',
              }
            }
          }
        }
      }
    }
  }
}

include_recipe 'glassfish::default'
include_recipe 'glassfish::attribute_driven_domain'

