# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
# require 'httplog'

class Client
  TESTNET_API_URL = "https://blockstream.info/testnet/api"
  TESTNET_API_POST_URL = "https://api.blockchair.com/bitcoin/testnet"

  def get(path)
    request(:get, uri(path))
  end

  def post(path, body)
    request(:post, push_uri(path), body)
  end

  private

  def request(method, url, body = nil)
    res = case method
          when :get then Net::HTTP.get_response(url)
          when :post then Net::HTTP.post_form(url, body)
          else { success: false }
          end

    unless res.is_a?(Net::HTTPSuccess)
      puts "Error response \n"
      return { success: false, response: res }
    end
    { success: true, response: JSON.parse(res.body) }
  end

  def uri(path)
    URI("#{TESTNET_API_URL}/#{path}")
  end

  def push_uri(path)
    URI("#{TESTNET_API_POST_URL}/#{path}")
  end
end
