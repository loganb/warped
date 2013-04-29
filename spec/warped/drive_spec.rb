require 'spec_helper'

describe Warped::Drive do
  
  it "completes" do 
    subject.complete(0)
  end
  
  it "closes" do
    subject.close
  end
  
  let(:str) { "foob".freeze }
  context "Reading" do
    let(:io) do
      (rp, wp) = ::IO.pipe
      wp << str
      wp.close
      subject.from_io(rp, :pipe)
    end
    
    let(:request) { Warped::IORequest.new("", 1024, nil) }
    
    it "completes" do
      io.read(request)
      subject.complete(1)
      request.should be_complete
      request.buffer.should 
    end
  end
  
  context "Writing" do
    let(:io) do
      (rp, wp) = ::IO.pipe
      Thread.new do
        true while(rp.read)
        rp.close
      end
      subject.from_io(wp, :pipe)
    end
    
    let(:request) { Warped::IORequest.new(str, nil, nil) }
    
    it "completes" do
      io.write(request)
      subject.complete(1)
      request.should be_complete
    end
  end
end