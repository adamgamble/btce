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
end
