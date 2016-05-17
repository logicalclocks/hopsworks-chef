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

describe service('JobHistoryServer') do  
  it { should be_running   }
end 

describe command("/var/lib/mysql-cluster/ndb/scripts/mysql-client.sh -e \"show databases\"") do
  its (:stdout) { should match /hops/ }
end

describe command("/var/lib/mysql-cluster/ndb/scripts/mgm-client.sh -e \"show\"") do
  its(:exit_status) { should eq 0 }
end

describe command("su glassfish -l -c \"/srv/hadoop/bin/hdfs dfs -ls /\"") do
  its (:stdout) { should match /mr-history/ }
end

describe command("su glassfish -l -c \"/srv/hadoop/bin/yarn jar /srv/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 1 1000 \"") do
  its (:stdout) { should match /Estimated value of Pi is/ }
end

describe service('ASMain') do  
  it { should be_running   }
end 

