require "rspec"
require "promkiq/middleware"

TestWorker = Class.new

describe Promkiq::Middleware do
  subject { Promkiq::Middleware.new(app: "yo", env: "test", gateway: "https://gateway.yo") }

  it "should raise argument error if bad args are given" do
    expect { Promkiq::Middleware.new }.to raise_error(ArgumentError)
  end

  it "should register prometheus metrics when initialized" do
    allow_any_instance_of(Prometheus::Client::Push).to receive(:add).and_return(nil)
    subject.call(TestWorker.new, nil, nil) do

    end
  end
end
