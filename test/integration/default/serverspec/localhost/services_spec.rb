require 'spec_helper'

#describe service('kagent') do  
#  it { should be_running   }
#end 


describe service('collectd-server') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('ASMain') do  
  it { should be_running   }
end 


