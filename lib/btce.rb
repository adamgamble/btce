require 'openssl'
require 'json'
require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'

module BTCE
  class MissingAPIKeyError < Exception;end
  class MissingAPISecretError < Exception;end
  class ServerResponseError < Exception;end

  class API
    attr_accessor :api_key, :api_secret
    def initialize options = {}
      @api_key    = options.fetch(:api_key)    { raise MissingAPIKeyError }
      @api_secret = options.fetch(:api_secret) { raise MissingAPISecretError }
    end

    def get_https(url, params = nil, sign = nil)
      uri = URI.parse url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      if params.nil?
        request = Net::HTTP::Get.new uri.request_uri
      else
        # If sending params, then we want a post request for authentication.
        request = Net::HTTP::Post.new uri.request_uri
        request.add_field "Key", API::KEY['key']
        request.add_field "Sign", sign
        request.set_form_data params
      end
      response = http.request request
      response.body
    end

    def get_json(url, params = nil, sign = nil)
      result = get_https(url, params, sign)
      JSON.load result
    end

    def getinfo
      get_json("https://btc-e.com/tapi/getinfo")
    end

    private
    def sign(data)
      OpenSSL::HMAC.hexdigest("sha512", @api_secret, data)
    end

    def nonce
      Time.now.to_i
    end
  end
end
