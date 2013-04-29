require 'spec_helper'

describe "Pipes" do
  let(:agent)  { Warped::Agent.new }
  let(:str)    { "Test String" }

  before(:each) do
    agent.submit(subject)
    agent.complete(1)
  end
  
  after(:each) do
    agent.close
  end

  describe "Reading" do
    let(:io) do
      (rp, wp) = ::IO.pipe
      wp << str
      wp.close
      agent.from_io(rp, :pipe)
    end
    
    subject { Warped::IORequest.new(io, :r, "", 1024) }
    
    it("completes") { should be_complete }
    it("receives the right data") { subject.buffer.should eq(str) }
  end
  
  describe "Writing" do
    let(:io) do
      (@rp, wp) = ::IO.pipe
      agent.from_io(wp, :pipe)
    end
    
    subject { Warped::IORequest.new(io, :w, str) }
    
    it("completes") { should be_complete }
    it("wrote the right data") do
      subject.io.close
      rp.read.should eq(str)
    end
  end
end