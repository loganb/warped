require_relative '../spec_helper'

describe Warped::Pool do
  it "Processes work" do
    subject.submit do
      sleep 0.1
      true
    end
    subject.result(2).should == true
  end
  
  it "Processes two things at once" do
    2.times do |i|
      subject.submit do
        sleep 0.1
        i
      end
    end

    Set.new(2.times.collect { subject.result(1) }).should eq(Set.new([0,1]))
  end
  
  it "Ignores nil results" do
    subject.submit { sleep(0.1); nil }
    subject.submit { sleep(0.2); true }
    subject.submit { sleep(0.3); nil }
    
    3.times.collect { subject.result(0.4) }.should eq([true, nil, nil])
  end
end