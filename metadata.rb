name             "hopsworks"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      "Installs/Configures HopsWorks, the UI for Hops Hadoop."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
source_url       "https://github.com/hopshadoop/hopsworks-chef"


%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

depends 'glassfish'
depends 'ndb'
depends 'kagent'
depends 'hops'
depends 'elastic'
depends 'hadoop_spark'
depends 'flink'
depends 'zeppelin'
depends 'compat_resource'
depends 'ulimit2'
depends 'authbind'
depends 'apache_hadoop'
depends 'epipe'
depends 'livy'
depends 'oozie'
depends 'kkafka'
depends 'kzookeeper'
depends 'drelephant'
depends 'dela'
depends 'java'

#link:Click <a target='_blank' href='https://%host%:4848'>here</a> to launch Glassfish in your browser (http)
recipe  "hopsworks::install", "Installs Glassfish"

#link:Click <a target='_blank' href='http://%host%:8080/hopsworks'>here</a> to launch hopsworks in your browser (http)
recipe  "hopsworks", "Installs HopsWorks war file, starts glassfish+application."

recipe  "hopsworks::dev", "Installs development libraries needed for HopsWorks development."

recipe  "hopsworks::letsencypt", "Given a glassfish installation and a letscrypt installation, update glassfish's key."

recipe  "hopsworks::purge", "Deletes glassfish installation."

recipe  "kagent::install", ""
recipe  "kagent::default", ""
recipe  "kagent::purge", ""

recipe  "ndb::install", ""
recipe  "ndb::ndbd", ""
recipe  "ndb::mgmd", ""
recipe  "ndb::mysqld", ""
recipe  "ndb::purge", ""

recipe  "apache_hadoop::install", ""
recipe  "apache_hadoop::nn", ""
recipe  "apache_hadoop::dn", ""
recipe  "apache_hadoop::rm", ""
recipe  "apache_hadoop::nm", ""
recipe  "apache_hadoop::jhs", ""
recipe  "apache_hadoop::purge", ""

recipe  "hadoop_spark::install", ""
recipe  "hadoop_spark::yarn", ""
recipe  "hadoop_spark::historyserver", ""
recipe  "hadoop_spark::purge", ""

recipe  "flink::install", ""
recipe  "flink::yarn", ""
recipe  "flink::purge", ""

recipe  "elastic::install", ""
recipe  "elastic::default", ""
recipe  "elastic::purge", ""

recipe  "kzookeeper::install", ""
recipe  "kzookeeper::default", ""
recipe  "kzookeeper::purge", ""

recipe  "kkafka::install", ""
recipe  "kkafka::default", ""
recipe  "kkafka::purge", ""

recipe  "livy::install", ""
recipe  "livy::default", ""
recipe  "livy::purge", ""

recipe  "epipe::install", ""
recipe  "epipe::default", ""
recipe  "epipe::purge", ""

recipe  "zeppelin::install", ""
recipe  "zeppelin::default", ""
recipe  "zeppelin::purge", ""

recipe  "drelephant::install", ""
recipe  "drelephant::default", ""
recipe  "drelephant::purge", ""

recipe  "dela::install", ""
recipe  "dela::default", ""
recipe  "dela::purge", ""



#######################################################################################
# Required Attributes
#######################################################################################


attribute "hopsworks/twofactor_auth",
          :description => "twofactor_auth (default: false)",
          :type => 'string',
          :required => "required"

attribute "hopsworks/gmail/email",
          :description => "Email address for gmail account",
          :required => "required",
          :type => 'string'

attribute "hopsworks/gmail/password",
          :description => "Password for gmail account",
          :required => "required",
          :type => 'string'

attribute "hopsworks/admin/user",
          :description => "Username for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "hopsworks/admin/password",
          :description => "Password for the Administration account on the Web Application Server",
          :type => 'string',
          :required => "required"

attribute "mysql/user",
          :description => "Username for the MySQL Server Accounts",
          :type => 'string',
          :required => "required"

attribute "mysql/password",
          :description => "Password for the MySQL Server Accounts",
          :type => 'string',
          :required => "required"

#######################################################################################
# Non-Required Attributes
#######################################################################################

attribute "hopsworks/master/password",
          :description => "Web Application Server master password",
          :type => 'string'

attribute "download_url",
          :description => "URL for downloading binaries",
          :type => 'string'

# attribute "hopsworks/cert/password",
#           :description => "hopsworks/cert/password",
#           :type => 'string',
#           :default => "changeit"

attribute "karamel/cert/cn",
          :description => "Certificate Name",
          :type => 'string'

attribute "karamel/cert/o",
          :description => "organization",
          :type => 'string'

attribute "karamel/cert/ou",
          :description => "Organization unit",
          :type => 'string'

attribute "karamel/cert/l",
          :description => "Location",
          :type => 'string'

attribute "karamel/cert/s",
          :description => "City",
          :type => 'string'

attribute "karamel/cert/c",
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

# attribute "glassfish/admin/port",
#           :description => "glassfish/admin/port",
#           :type => 'string'

# attribute "glassfish/port",
#           :description => "glassfish/port",
#           :type => 'string'


attribute "hopsworks/port",
          :description => "Port that webserver will listen on",
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


attribute "hopsworks/max_perm_size",
          :description => "glassfish/max_perm_size",
          :type => 'string'

attribute "kagent/enabled",
          :description =>  "Install kagent",
          :type => 'string'

attribute "hopsworks/reinstall",
          :description => "Enter 'true' if this is a reinstallation",
          :type => 'string'

attribute "hopsworks/war_url",
          :description => "Url for the hopsworks war file",
          :type => 'string'

attribute "hopsworks/yarn_default_quota_mins",
          :description => "Default number of CPU mins availble per project",
          :type => 'string'

attribute "hopsworks/hdfs_default_quota_gbs",
          :description => "Default amount in GB of available storage per project",
          :type => 'string'

attribute "hopsworks/max_num_proj_per_user",
          :description => "Maximum number of projects that can be created by each user",
          :type => 'string'

attribute "glassfish/package_url",
          :description => "Url for the Glassfish distribution zip file.",
          :type => 'string'

attribute "ndb/dir",
          :description => "Ndb Installation directory.",
          :type => 'string'

attribute "hops/dir",
          :description => "Ndb Installation directory.",
          :type => 'string'

attribute "hadoop_spark/dir",
          :description => "Installation directory.",
          :type => 'string'

attribute "hopsworks.kafka_num_replicas",
          :description => "Default number of replicas for Kafka Topics.",
          :type => 'string'

attribute "hopsworks.kafka_num_partitions",
          :description => "Default number of partitions for Kafka Topics.",
          :type => 'string'

attribute "hopsworks/file_preview_image_size",
          :description => "Maximum size in bytes of an image that can be previewed in DataSets",
          :type => 'string'

attribute "hopsworks/file_preview_txt_size",
          :description => "Maximum size in lines of file that can be previewed in DataSets",
          :type => 'string'

attribute "java/jdk_version",
          :display_name =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :display_name =>  "Oracle (default) or openjdk",
          :type => 'string'


#########################################################################
#########################################################################
### BEGIN GENERATED CONTENT

attribute "kagent/user",
          :description => "Username to run kagent as",
          :type => 'string'

attribute "kagent/dashboard/ip",
          :description => " Ip address for Dashboard REST API",
          :type => 'string'

attribute "kagent/dashboard/port",
          :description => " Port for Dashboard REST API",
          :type => 'string'

attribute "hop/hostid",
          :description => " One-time password used when registering the host",
          :type => 'string'

attribute "kagent/name",
          :description => "Cookbook name",
          :type => 'string'

attribute "kagent/rest_api/user",
          :description => "kagent REST API username",
          :type => "string"

attribute "kagent/rest_api/password",
          :description => "kagent REST API  password",
          :type => "string"

attribute "kagent/dashboard/user",
          :description => "kagent username to register with server",
          :type => "string"

attribute "kagent/dashboard/password",
          :description => "kagent password to register with server",
          :type => "string"

attribute "ndb/mysql_port",
          :description => "Port for the mysql server",
          :type => "string"

attribute "ndb/mysql_socket",
          :description => "Socket for the mysql server",
          :type => "string"

attribute "systemd",
          :description => "Use systemd startup scripts, default 'true'",
          :type => "string"

attribute "kagent/network/interface",
          :description => "Define the network intefaces (eth0, enp0s3)",
          :type => "string"

attribute "ntp/install",
          :description => "Install Network Time Protocol (default: false)",
          :type => "string"
attribute "ndb/package_url",
          :description => "Download URL for MySQL Cluster binaries",
          :type => 'string'

attribute "ndb/MaxNoOfExecutionThreads",
          :description => "Number of execution threads for MySQL Cluster",
          :type => 'string'

attribute "ndb/DataMemory",
          :description => "Data memory for each MySQL Cluster Data Node",
          :type => 'string',
          :required => "required"

attribute "ndb/IndexMemory",
          :description => "Index memory for each MySQL Cluster Data Node",
          :type => 'string'

attribute "memcached/mem_size",
          :description => "Memcached data memory size",
          :type => 'string'

attribute "ndb/version",
          :description =>  "MySQL Cluster Version",
          :type => 'string'

attribute "ndb/user",
          :description => "User that runs ndb database",
          :type => 'string'

attribute "ndb/group",
          :description => "Group that runs ndb database",
          :type => 'string'

attribute "mysql/user",
          :description => "User that runs mysql server",
          :required => "required",
          :type => 'string'

attribute "mysql/password",
          :description => "Password for hop mysql user",
          :required => "required",
          :type => 'string'

#
# Optional Parameters/Attributes
#

attribute "mysql/dir",
          :description => "Directory in which to install MySQL Binaries",
          :type => 'string'

attribute "mysql/replication_enabled",
          :description => "Enable replication for the mysql server",
          :type => 'string'

attribute "ndb/wait_startup",
          :description => "Max amount of time a MySQL server should wait for the ndb nodes to be up",
          :type => 'string'

attribute "ndb/mgm_server/port",
          :description => "Port used by Mgm servers in MySQL Cluster",
          :type => 'string'

attribute "ndb/NoOfReplicas",
          :description => "Num of replicas of the MySQL Cluster Data Nodes",
          :type => 'string'

attribute "ndb/FragmentLogFileSize",
          :description => "FragmentLogFileSize",
          :type => 'string'

attribute "ndb/MaxNoOfAttributes",
          :description => "MaxNoOfAttributes",
          :type => 'string'

attribute "ndb/MaxNoOfConcurrentIndexOperations",
          :description => "Increase for higher throughput at the cost of more memory",
          :type => 'string'

attribute "ndb/MaxNoOfConcurrentOperations",
          :description => "Increase for higher throughput at the cost of more memory",
          :type => 'string'

attribute "ndb/MaxNoOfTables",
          :description => "MaxNoOfTables",
          :type => 'string'

attribute "ndb/MaxNoOfOrderedIndexes",
          :description => "MaxNoOfOrderedIndexes",
          :type => 'string'

attribute "ndb/MaxNoOfUniqueHashIndexes",
          :description => "MaxNoOfUniqueHashIndexes",
          :type => 'string'

attribute "ndb/MaxDMLOperationsPerTransaction",
          :description => "MaxDMLOperationsPerTransaction",
          :type => 'string'

attribute "ndb/TransactionBufferMemory",
          :description => "TransactionBufferMemory",
          :type => 'string'

attribute "ndb/MaxParallelScansPerFragment",
          :description => "MaxParallelScansPerFragment",
          :type => 'string'

attribute "ndb/MaxDiskWriteSpeed",
          :description => "MaxDiskWriteSpeed",
          :type => 'string'

attribute "ndb/MaxDiskWriteSpeedOtherNodeRestart",
          :description => "MaxDiskWriteSpeedOtherNodeRestart",
          :type => 'string'

attribute "ndb/MaxDiskWriteSpeedOwnRestart",
          :description => "MaxDiskWriteSpeedOwnRestart",
          :type => 'string'

attribute "ndb/MinDiskWriteSpeed",
          :description => "MinDiskWriteSpeed",
          :type => 'string'

attribute "ndb/DiskSyncSize",
          :description => "DiskSyncSize",
          :type => 'string'

attribute "ndb/RedoBuffer",
          :description => "RedoBuffer",
          :type => 'string'

attribute "ndb/LongMessageBuffer",
          :description => "LongMessageBuffer",
          :type => 'string'

attribute "ndb/TransactionInactiveTimeout",
          :description => "TransactionInactiveTimeout",
          :type => 'string'

attribute "ndb/TransactionDeadlockDetectionTimeout",
          :description => "TransactionDeadlockDetectionTimeout",
          :type => 'string'

attribute "ndb/LockPagesInMainMemory",
          :description => "LockPagesInMainMemory",
          :type => 'string'

attribute "ndb/RealTimeScheduler",
          :description => "RealTimeScheduler",
          :type => 'string'

attribute "ndb/SchedulerSpinTimer",
          :description => "SchedulerSpinTimer",
          :type => 'string'

attribute "ndb/BuildIndexThreads",
          :description => "BuildIndexThreads",
          :type => 'string'

attribute "ndb/CompressedLCP",
          :description => "CompressedLCP",
          :type => 'string'

attribute "ndb/CompressedBackup",
          :description => "CompressedBackup",
          :type => 'string'

attribute "ndb/BackupMaxWriteSize",
          :description => "BackupMaxWriteSize",
          :type => 'string'

attribute "ndb/BackupLogBufferSize",
          :description => "BackupLogBufferSize",
          :type => 'string'

attribute "ndb/BackupDataBufferSize",
          :description => "BackupDataBufferSize",
          :type => 'string'

attribute "ndb/MaxAllocate",
          :description => "MaxAllocate",
          :type => 'string'

attribute "ndb/DefaultHashMapSize",
          :description => "DefaultHashMapSize",
          :type => 'string'

attribute "ndb/ODirect",
          :description => "ODirect",
          :type => 'string'

attribute "ndb/TotalSendBufferMemory",
          :description => "TotalSendBufferMemory in MBs",
          :type => 'string'

attribute "ndb/OverloadLimit",
          :description => "Overload for Send/Recv TCP Buffers in MBs",
          :type => 'string'

attribute "kagent/enabled",
          :description =>  "Install kagent",
          :type => 'string',
          :required => "optional"

attribute "ndb/NoOfFragmentLogParts",
          :description =>  "One per ldm thread. Valid values: 4, 8, 16. Should match the number of CPUs in ThreadConfig's ldm threads.",
          :type => 'string'

attribute "ndb/bind_cpus",
          :description =>  "Isolate interrupts from cpus, turn off balance_irqs",
          :type => 'string'

attribute "ndb/TcpBind_INADDR_ANY",
          :description =>  "Set to TRUE so that any IP addr can be used on any node. Default is FALSE.",
          :type => 'string'

attribute "ndb/aws_enhanced_networking",
          :description =>  "Set to true if you want the ixgbevf module to be installed that is needed for AWS enhanced networking.",
          :type => 'string'

attribute "ndb/interrupts_isolated_to_single_cpu",
          :description =>  "Set to true if you want to setup your linux kernal to handle interrupts on a single CPU.",
          :type => 'string'

attribute "ndb/ThreadConfig",
          :description => "Decide which threads bind to which cores: Threadconfig=main={cpubind=0},ldm={count=8,cpubind=1,2,3,4,13,14,15,16},io={count=4,cpubind=5,6,17,18},rep={cpubind=7},recv={count=2,cpubind=8,19}k",
          :type => 'string'

attribute "ndb/dir",
          :description =>  "Directory in which to install mysql-cluster",
          :type => 'string'

attribute "ndb/shared_folder",
          :description =>  "Directory in which to download mysql-cluster",
          :type => 'string'

attribute "ndb/systemd",
          :description =>  "Use systemd scripts (instead of system-v). Default is 'true'.",
          :type => 'string'

attribute "ndb/MaxNoOfConcurrentTransactions",
          :description =>  "Maximum number of concurrent transactions (higher consumes more memory)",
          :type => 'string'


# attribute "btsync/ndb/seeder_secret",
# :display_name => "Ndb seeder's random secret key.",
# :description => "20 chars or more (normally 32 chars)",
# :type => 'string',
# :default => "AY27AAZKTKO3GONE6PBCZZRA6MKGRKBX2"

# attribute "btsync/ndb/leecher_secret",
# :display_name => "Ndb leecher's secret key.",
# :description => "Ndb's random secret (key) generated using the seeder's secret key. 20 chars or more (normally 32 chars)",
# :type => 'string',
# :default => "BTHKJKK4PIPIOJZ7GITF2SJ2IYDLSSJVY"
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "hops/yarn/rm_heartbeat",
          :description => "NodeManager heartbeat timeout",
          :type => 'string'

attribute "mysql/user",
          :description => "Mysql server username",
          :type => 'string',
          :required => "required"

attribute "mysql/password",
          :description => "MySql server Password",
          :type => 'string',
          :required => "required"

attribute "hops/use_hopsworks",
          :description => "'true' or 'false' - true to enable HopsWorks support",
          :type => 'string'

attribute "hops/erasure_coding",
          :description => "'true' or 'false' - true to enable erasure-coding replication",
          :type => 'string'

attribute "hops/nn/direct_memory_size",
          :description => "Size of the direct memory size for the NameNode in MBs",
          :type => 'string'

attribute "hops/nn/heap_size",
          :description => "Size of the NameNode heap in MBs",
          :type => 'string'

attribute "hops/nn/cache",
          :description => "'true' or 'false' - true to enable the path cache in the NameNode",
          :type => 'string'

attribute "hops/nn/partition_key",
          :description => "'true' or 'false' - true to enable the partition key when starting transactions. Distribution-aware transactions.",
          :type => 'string'

attribute "hops/yarn/resource_tracker",
          :description => "Hadoop Resource Tracker enabled on this nodegroup",
          :type => 'string'

attribute "hops/install_db",
          :description => "Install hops database and tables in MySQL Cluster ('true' (default) or 'false')",
          :type => 'string'

attribute "hops/dir",
          :description => "Base installation directory for HopsFS",
          :type => 'string'


attribute "hops/use_systemd",
          :description => "Use systemd startup scripts, default 'false'",
          :type => "string"

attribute "apache_hadoop/group",
          :description => "Group to run hdfs/yarn/mr as",
          :type => 'string'


#
# wrapper parameters 
#

attribute "apache_hadoop/yarn/nm/memory_mbs",
          :description => "Apache_Hadoop NodeManager Memory in MB",
          :type => 'string'

attribute "apache_hadoop/yarn/vcores",
          :description => "Apache_Hadoop NodeManager Number of Virtual Cores",
          :type => 'string'

attribute "apache_hadoop/yarn/max_vcores",
          :description => "Hadoop NodeManager Maximum Virtual Cores per container",
          :type => 'string'

attribute "apache_hadoop/version",
          :description => "Hadoop version",
          :type => 'string'

attribute "apache_hadoop/num_replicas",
          :description => "HDFS replication factor",
          :type => 'string'

attribute "apache_hadoop/container_cleanup_delay_sec",
          :description => "The number of seconds container data is retained after termination",
          :type => 'string'

attribute "apache_hadoop/yarn/user",
          :description => "Username to run yarn as",
          :type => 'string'

attribute "apache_hadoop/mr/user",
          :description => "Username to run mapReduce as",
          :type => 'string'

attribute "apache_hadoop/hdfs/user",
          :description => "Username to run hdfs as",
          :type => 'string'

attribute "apache_hadoop/format",
          :description => "Format HDFS",
          :type => 'string'

attribute "apache_hadoop/tmp_dir",
          :description => "The directory in which Hadoop stores temporary data, including container data",
          :type => 'string'

attribute "apache_hadoop/data_dir",
          :description => "The directory in which Hadoop's DataNodes store their data",
          :type => 'string'

attribute "apache_hadoop/yarn/nodemanager_hb_ms",
          :description => "Heartbeat Interval for NodeManager->ResourceManager in ms",
          :type => 'string'

attribute "apache_hadoop/container_cleanup_delay_sec",
          :description => "The number of seconds container data is retained after termination",
          :type => 'string'

attribute "apache_hadoop/rm/scheduler_class",
          :description => "Java Classname for the Yarn scheduler (fifo, capacity, fair)",
          :type => 'string'

attribute "apache_hadoop/rm/scheduler_capacity/calculator_class",
          :description => "YARN resource calculator class. Switch to DominantResourseCalculator for multiple resource scheduling",
          :type => 'string'

attribute "apache_hadoop/user_envs",
          :description => "Update the PATH environment variable for the hdfs and yarn users to include hadoop/bin in the PATH ",
          :type => 'string'

attribute "apache_hadoop/logging_level",
          :description => "Log levels are: TRACE, DEBUG, INFO, WARN",
          :type => 'string'

attribute "apache_hadoop/nn/heap_size",
          :description => "Size of the NameNode heap in MBs",
          :type => 'string'

attribute "apache_hadoop/nn/direct_memory_size",
          :description => "Size of the direct memory size for the NameNode in MBs",
          :type => 'string'

attribute "apache_hadoop/ha_enabled",
          :description => "'true' to enable HA, else 'false'",
          :type => 'string'

attribute "apache_hadoop/yarn/rt",
          :description => "Hadoop Resource Tracker enabled on this nodegroup",
          :type => 'string'

attribute "apache_hadoop/dir",
          :description => "Hadoop installation directory",
          :type => 'string'

attribute "hops/yarn/rm_distributed",
          :description => "Set to 'true' for distribute yarn",
          :type => "string"

attribute "hops/yarn/nodemanager_ha_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_auto_failover_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_recovery_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/rm_heartbeat",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_rpc_batch_max_size",
          :description => "",
          :type => "string"

attribute "hops/yarn/nodemanager_rpc_batch_max_duration",
          :description => "",
          :type => "string"

attribute "hops/yarn/rm_distributed",
          :description => "Set to 'true' to enable distributed RMs",
          :type => "string"

attribute "hops/yarn/nodemanager_rm_streaming_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/client_failover_sleep_base_ms",
          :description => "",
          :type => "string"

attribute "hops/yarn/client_failover_sleep_max_ms",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_enabled",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_monitor_interval",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_ticks_per_credit",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_min_ticks_charge",
          :description => "",
          :type => "string"

attribute "hops/yarn/quota_checkpoint_nbticks",
          :description => "",
          :type => "string"
attribute "java/jdk_version",
          :display_name =>  "Jdk version",
          :type => 'string'

attribute "hadoop_spark/user",
          :display_name => "Username to run spark master/worker as",
          :type => 'string'

attribute "hadoop_spark/group",
          :display_name => "Groupname to run spark master/worker as",
          :type => 'string'

attribute "hadoop_spark/executor_memory",
          :display_name => "Executor memory (e.g., 512m)",
          :type => 'string'

attribute "hadoop_spark/driver_memory",
          :display_name => "Driver memory (e.g., 1g)",
          :type => 'string'

attribute "hadoop_spark/eventlog_enabled",
          :display_name => "Eventlog enabled (true|false)",
          :type => 'string'

attribute "hadoop_spark/worker/cleanup/enabled",
          :display_name => "Spark standalone worker cleanup enabled (true|false)",
          :type => 'string'

attribute "hadoop_spark/version",
          :display_name => "Spark version (e.g., 1.4.1 or 1.5.2 or 1.6.0)",
          :type => 'string'

attribute "hadoop_spark/hadoop/distribution",
          :display_name => "'hops' or 'apache_hadoop'",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/enabled",
          :display_name => "'true' to enable cleanup of the historyservers logs",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/interval",
          :display_name => "How often to run the cleanup of the historyservers logs (e.g., '1d' for once per day)",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/maxAge",
          :display_name => "Age in days of the historyservers logs before they are removed (e.g., '7d' for 7 days)",
          :type => 'string'
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "flink/user",
          :description => "Username to run flink jobmgr/task as",
          :type => 'string'

attribute "flink/group",
          :description => "Groupname to run flink jobmgr/task as",
          :type => 'string'

attribute "flink/mode",
          :description => "Run Flink JobManager in one of the following modes: BATCH, STREAMING",
          :type => 'string'

attribute "flink/jobmanager/heap_mbs",
          :description => "Flink JobManager Heap Size in MB",
          :type => 'string'

attribute "flink/taskmanager/heap_mbs",
          :description => "Flink TaskManager Heap Size in MB",
          :type => 'string'

attribute "flink/dir",
          :description => "Root directory for flink installation",
          :type => 'string'

attribute "flink/taskmanager/num_taskslots",
          :description => "Override the default number of task slots (default = NoOfCPUs)",
          :type => 'string'

attribute "flink/hadoop/distribution",
          :description => "apache_hadoop (default) or hops",
          :type => 'string'
attribute "epipe/user",
          :description => "User to run Epipe server as",
          :type => "string"

attribute "epipe/group",
          :description => "Group to run Epipe server as",
          :type => "string"

attribute "epipe/version",
          :description => "Version of epipe to use",
          :type => "string"

attribute "epipe/url",
          :description => "Url to epipe binaries",
          :type => "string"

attribute "epipe/dir",
          :description => "Parent directory to install epipe in (/srv is default)",
          :type => "string"

attribute "epipe/pid_file",
          :description => "Change the location for the pid_file.",
          :type => "string"
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "livy/user",
          :description => "User to install/run as",
          :type => 'string'

attribute "livy/dir",
          :description => "base dir for installation",
          :type => 'string'

attribute "livy/version",
          :dscription => "livy.version",
          :type => "string"

attribute "livy/url",
          :dscription => "livy.url",
          :type => "string"

attribute "livy/port",
          :dscription => "livy.port",
          :type => "string"

attribute "livy/home",
          :dscription => "livy.home",
          :type => "string"

attribute "livy/keystore",
          :dscription => "ivy.keystore",
          :type => "string"

attribute "livy/keystore_password",
          :dscription => "ivy.keystore_password",
          :type => "string"
attribute "dela/group",
          :description => "group parameter value",
          :type => "string"

attribute "dela/user",
          :description => "user parameter value",
          :type => "string"

attribute "java/jdk_version",
          :description => "Version of Java to use (e.g., '7' or '8')",
          :type => "string"

attribute "dela/id",
          :description => "id for the dela instance. Randomly generated, but can be ovverriden here.",
          :type => "string"

attribute "dela/seed",
          :description => "seed for the dela instance. Randomly generated, but can be ovverriden here.",
          :type => "string"

attribute "dela/log_level",
          :description => "Default: WARN. Can be INFO or DEBUG or TRACE or ERROR.",
          :type => "string"

attribute "dela/stun_port1",
          :description => "1st Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/stun_port2",
          :description => "2nd Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/stun_client_port1",
          :description => "1st Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/stun_client_port2",
          :description => "2nd Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/port",
          :description => "Dela Client application port.",
          :type => "string"

attribute "dela/http-port",
          :description => "Dela Client http port.",
          :type => "string"
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "kzookeeper/version",
          :description => "Version of kzookeeper",
          :type => 'string'

attribute "kzookeeper/url",
          :description => "Url to download binaries for kzookeeper",
          :type => 'string'

attribute "kzookeeper/user",
          :description => "Run kzookeeper as this user",
          :type => 'string'

attribute "kzookeeper/group",
          :description => "Run kzookeeper user as this group",
          :type => 'string'
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "kafka/ulimit",
          :description => "ULimit for the max number of open files allowed",
          :type => 'string'

attribute "kkafka/offset_monitor/port",
          :description => "Port for Kafka monitor service",
          :type => 'string'

attribute "kkafka/memory_mb",
          :description => "Kafka server memory in mbs",
          :type => 'string'

attribute "kkafka/broker/zookeeper_connection_timeout_ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/hours",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/size",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/message/max/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/network/threads",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/io/threads",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/recovery/threads/per/data/dir",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/replica/fetchers",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/queued/max/requests",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/socket/send/buffer/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/brattribute oker/socket/receive/buffer/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/sockeattribute t/request/max/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/num/partitionsattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/segment/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/roll/hoursattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/hoursattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/retention/check/interval/attribute ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/index/size/max/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/index/interval/bytesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/interval/messagesattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/scheduler/interval/msattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/interval/msattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/leader/imbalance/check/intervalattribute /seconds",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/leader/imbalance/per/broker/percentageattribute ",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/dir",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/flush/offset/checkpoint/interval/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/port",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/queued/max/requests",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/quota/consumer/default",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/quota/producer/default",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/fetch/max/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/fetch/min/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/fetch/wait/max/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/high/watermark/checkpoint/interval/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/lag/time/max/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/socket/receive/buffer/bytes",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replica/socket/timeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/request/timeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/session/timeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/set/acl",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/replication/factor",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/cleaner/enable",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/log/cleaner/io/buffer/load/factor",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/security/inter/broker/protocol",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/client/auth",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/key/password",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/keystore/location",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/keystore/password",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/truststore/location",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/truststore/password",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/authorizer/class/name",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/ssl/endpoint/identification/algorithm",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/principal/builder/class",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/synctime/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/connectiontimeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/sessiontimeout/ms",
          :description => "",
          :type => 'string'

attribute "kkafka/broker/zookeeper/synctime/ms",
          :description => "",
          :type => 'string'
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "elastic/port",
          :description =>  "Port for elasticsearch service (default: 9200)",
          :type => 'string'

attribute "elastic/ulimit_files",
          :description =>  "Number of files to set ulimit to.",
          :type => 'string'

attribute "elastic/ulimit_memlock",
          :description =>  "Memlock size for ulimit",
          :type => 'string'

attribute "elastic/dir",
          :description =>  "Base directory to install elastic search into.",
          :type => 'string'

attribute "elastic/memory",
          :description =>  "Amount of memory for Elasticsearch.",
          :type => 'string'

attribute "elastic/version",
          :description =>  "Elasticsearch version, .e.g, '2.1.2'",
          :type => 'string'

attribute "elastic/checksum",
          :description =>  "Sha-1 checksum for the elasticsearch .tar.gz file",
          :type => 'string'
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "drelephant/user",
          :description => "Username that runs the Dr Elephant server",
          :type => 'string'

attribute "drelephant/port",
          :description => "Port for running the Dr Elephant server",
          :type => 'string'
attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "zeppelin/user",
          :description => "User to install/run zeppelin as",
          :type => 'string'

attribute "zeppelin/dir",
          :description => "zeppelin base dir",
          :type => 'string'
attribute "dela/group",
          :description => "group parameter value",
          :type => "string"

attribute "dela/user",
          :description => "user parameter value",
          :type => "string"

attribute "java/jdk_version",
          :description => "Version of Java to use (e.g., '7' or '8')",
          :type => "string"

attribute "dela/id",
          :description => "id for the dela instance. Randomly generated, but can be ovverriden here.",
          :type => "string"

attribute "dela/seed",
          :description => "seed for the dela instance. Randomly generated, but can be ovverriden here.",
          :type => "string"

attribute "dela/log_level",
          :description => "Default: WARN. Can be INFO or DEBUG or TRACE or ERROR.",
          :type => "string"

attribute "dela/stun_port1",
          :description => "1st Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/stun_port2",
          :description => "2nd Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/stun_client_port1",
          :description => "1st Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/stun_client_port2",
          :description => "2nd Client port used by stun client in Dela.",
          :type => "string"

attribute "dela/port",
          :description => "Dela Client application port.",
          :type => "string"

attribute "dela/http-port",
          :description => "Dela Client http port.",
          :type => "string"
