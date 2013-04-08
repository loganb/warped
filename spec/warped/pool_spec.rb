require_relative '../spec_helper'

describe Warped::Pool do
  # Simple worker that does some basic math
  subject do
    described_class.new do |x, y, sleep|
      sleep(sleep)
      x + y unless(x.nil? || y.nil?)
    end
  end
  
  it "Processes work" do
    subject.submit(1, 1, 0.1)
    
    subject.result(2).should == 2
  end
  
  it "Processes two things at once" do
    2.times do |i|
      subject.submit(0, i, i.to_f/10)
    end

    Set.new(2.times.collect { subject.result(1) }).should eq(Set.new([0,1]))
  end
  
  it "Ignores nil results" do
    subject.submit(nil, nil, 0.1)
    subject.submit(1, 0, 0.1)
    subject.submit(nil, nil, 0.1)
    
    3.times.collect { subject.result(0.4) }.should eq([1, nil, nil])
  end
end