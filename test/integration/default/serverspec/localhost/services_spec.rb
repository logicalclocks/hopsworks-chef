require 'spec_helper'


describe service('namenode') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('datanode') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('resourcemanager') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('nodemanager') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('jobhistoryserver') do  
  it { should be_running   }
end 

describe command("/srv/hops/mysql-cluster/ndb/scripts/mysql-client.sh -e \"show databases\"") do
  its (:stdout) { should match /hops/ }
end

describe command("/srv/hops/mysql-cluster/ndb/scripts/mgm-client.sh -e \"show\"") do
  its(:exit_status) { should eq 0 }
end

describe command("su glassfish -l -c \"/srv/hops/hadoop/bin/hdfs dfs -ls /\"") do
  its (:stdout) { should match /mr-history/ }
end

describe command("su glassfish -l -c \"/srv/hops/hadoop/bin/yarn jar /srv/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 1 1000 \"") do
  its (:stdout) { should match /Estimated value of Pi is/ }
end

describe service('ASMain') do  
  it { should be_running   }
end 

describe service('sparkhistoryserver') do
  it { should be_enabled   }
  it { should be_running   }
end

describe command("service sparkhistoryserver restart") do
  its(:exit_status) { should eq 0 }
end


describe command("su spark -l -c \"HADOOP_CONF_DIR=/srv/hops/hadoop/etc/hadoop /srv/hops/spark/bin/spark-submit --verbose --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client --driver-memory 512m --executor-memory 512m --queue default --num-executors 1 /srv/hops/spark/examples/jars/spark-examples_2.11-2.1.0.jar 100\"") do
  its (:stdout) { should match /Pi is roughly/ }
end

# When you run in cluster-mode, spark-submit works ok, but doesn't return, so this fails
describe command("su spark -l -c \"HADOOP_CONF_DIR=/srv/hops/hadoop/etc/hadoop /srv/hops/spark/bin/spark-submit --verbose --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster --driver-memory 512m --executor-memory 512m --queue default --num-executors 1 /srv/hops/spark/examples/jars/spark-examples_2.11-2.1.0.jar 100\"") do
  its(:exit_status) { should eq 0 }
end

