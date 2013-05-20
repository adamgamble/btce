require 'openssl'
require 'json'
require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'

module BTCE
  BTCE_API_URL = "https://btc-e.com/tapi"
  class MissingAPIKeyError < Exception;end
  class MissingAPISecretError < Exception;end
  class ServerResponseError < Exception;end

  class API
    attr_accessor :api_key, :api_secret

    def initialize options = {}
      @api_key    = options.fetch(:api_key)    { raise MissingAPIKeyError }
      @api_secret = options.fetch(:api_secret) { raise MissingAPISecretError }
    end

    def get_https(params = {})
      params.merge!({:nonce => nonce})
      uri = URI.parse BTCE_API_URL
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

    def get_json(params = {})
      result = get_https(params)
      JSON.load result
    end

    def balance
      get_json :method => "getInfo"
    end

    def transaction_history
      get_json :method => "TransHistory"
    end

    def order_list
      get_json :method => "OrderList"
    end

    def trade pair = "btc_usd", type, rate, amount
      get_json method: "Trade", pair: pair, type: type, rate: rate, amount: amount
    end

    def cancel_order order_id
      get_json method: "CancelOrder", order_id: order_id
    end

    private
    def sign_params(params)
      params = params.collect {|k,v| "#{k}=#{v}"}.join('&')
      hmac = OpenSSL::HMAC.new(@api_secret, OpenSSL::Digest::SHA512.new)
      hmac.update params
    end

    def nonce
      Time.now.to_i
    end
  end
end
