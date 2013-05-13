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

    def get_https(url, params = {})
      params.merge!({:nonce => nonce})
      uri = URI.parse url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new uri.request_uri
      request.add_field "Sign", sign_params(params)
      request.add_field "Key", @api_key
      request.set_form_data params
      response = http.request request
      response.body
    end

    def get_json(url, params = {})
      result = get_https(url, params)
      JSON.load result
    end

    def getinfo
      get_json("https://btc-e.com/tapi/getinfo")
    end

    private
    def sign_params(params)
      data = "?"
      params.each_pair do |key, value|
        data += "#{key}=#{value}"
      end
      puts "Signing #{data}"
      signed = OpenSSL::HMAC.hexdigest("sha512", @api_secret, data)
      puts signed
      signed
    end

    def nonce
      Time.now.to_i
    end
  end
end
