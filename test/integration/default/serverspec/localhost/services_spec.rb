require 'spec_helper'

describe service('ASMain') do  
  it { should be_running   }
end 

describe service('kagent') do  
  it { should be_running   }
end 

describe service('collectd') do  
  it { should be_running   }
end 

describe service('collectd-server') do  
  it { should be_running   }
end 

describe command("cat /var/lib/kagent/agent.log") do
  it { should return_stdout /Sending heartbeat.../ }
end
