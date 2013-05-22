require 'btce'

describe BTCE::API do
  describe "#new" do
    it "should raise MissingAPIKeyError when you don't pass an api key" do
      expect { BTCE::API.new :api_secret => "blah" }.to raise_error(BTCE::MissingAPIKeyError)
    end

    it "should raise MissingAPISecretError when you don't pass an api secret" do
      expect { BTCE::API.new :api_key => "blah" }.to raise_error(BTCE::MissingAPISecretError)
    end
  end

  describe "#nonce" do
    before(:each) do
      @api = BTCE::API.new :api_secret => "blah", :api_key => "blag"
    end

    it "should return 1 for the first nonce" do
      @api.send(:nonce).should == "1"
    end

    it "should return 2 for the second nonce" do
      @api.send(:nonce)
      @api.send(:nonce).should == "2"
    end
  end
end
