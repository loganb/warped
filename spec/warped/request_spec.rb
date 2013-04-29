require_relative '../spec_helper'

describe Warped::Request do
  
  it "is not working when constructed" do
    should_not be_working
  end
  
  context "that has begun" do
    before(:each) { subject.begin! }
    it { should be_working }
    it { should_not be_complete }

    it "should not reset" do
       expect { subject.reset! }.to raise_exception
     end
  end
  
  context "that has completed" do
    before(:each) do
      subject.begin!
      subject.complete!
    end
    
    it { should_not be_working }
    it { should be_complete }
    
    it "should reset" do
      expect { subject.reset! }.to_not raise_exception
    end
  end
end