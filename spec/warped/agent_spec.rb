require 'spec_helper'

describe Warped::Agent do
  
  it "processes" do 
    subject.process
    
  end
  
  it "closes" do
    subject.close
  end
end