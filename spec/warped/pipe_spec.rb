require 'spec_helper'

describe "Pipes" do
  let(:agent)  { Warped::Agent.new }
  let(:str)    { "Test String" }

  describe "Reading" do
    let(:io) do
      (rp, wp) = ::IO.pipe
      wp << str
      wp.close
      agent.from_io(rp, :pipe)
    end
    
    subject { Warped::IORequest.new(io, :r, 1024) }
    
    before(:each) do
      agent.submit(subject)
      agent.process(1)
    end
    
    it("completes") { should be_complete }
  end
  
  describe "Writing" do
    
    it "writes" do
      
    end
  end
end