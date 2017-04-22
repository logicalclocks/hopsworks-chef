# Add spark log4j.properties file to HDFS. Used by Logstash.

template "#{Chef::Config["file_cache_path"]}/log4j.properties" do
  source "app.log4j.properties.erb"
  owner node["hadoop_spark"]["user"]
  mode 0750
  action :create
  variables({
               :private_ip => private_ip
  })
end


hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/log4j.properties" do
  action :put_as_superuser
  owner node["hadoop_spark"]["user"]
  group node["hops"]["group"]
  mode "1775"
  dest "/user/" + node["glassfish"]["user"] + "/log4j.properties"
end

# Add spark metrics.properties file to HDFS. Used by Grafana.

template "#{Chef::Config["file_cache_path"]}/metrics.properties" do
  source "metrics.properties.erb"
  owner node["glassfish"]["user"]
  mode 0750
  action :create
  variables({
               :private_ip => private_ip
  })
end


hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/metrics.properties" do
  action :put_as_superuser
  owner node["hadoop_spark"]["user"]
  group node["hops"]["group"]
  mode "1775"
  dest "/user/" + node["glassfish"]["user"] + "/metrics.properties"
end	


hopsUtil=File.basename(node["hops"]["hops_util"]["url"])
 
remote_file "#{Chef::Config["file_cache_path"]}/#{hopsUtil}" do
  source node["hops"]["hops_util"]["url"]
  owner node["glassfish"]["user"]
  group node["glassfish"]["group"]
  mode "1775"
  action :create
end

hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/hops-util-0.1.jar" do
  action :put_as_superuser
  owner node["glassfish"]["user"]
  group node["hops"]["group"]
  mode "1755"
  dest "/user/" + node["glassfish"]["user"] + "/hops-util-0.1.jar"
end

hopsKafkaJar=File.basename(node["hops"]["hops_spark_kafka_example"]["url"])
 
remote_file "#{Chef::Config["file_cache_path"]}/#{hopsKafkaJar}" do
  source node["hops"]["hops_spark_kafka_example"]["url"]
  owner node["glassfish"]["user"]
  group node["glassfish"]["group"]
  mode "1775"
  action :create
end

hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/#{hopsKafkaJar}" do
  action :put_as_superuser
  owner node["glassfish"]["user"]
  group node["hops"]["group"]
  mode "1755"
  dest "/user/" + node["glassfish"]["user"] + "/#{hopsKafkaJar}"
end

