# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'httplog'

class Client
  TESTNET_API_URL = "https://blockstream.info/testnet/api"
  TESTNET_API_POST_URL = "https://api.blockchair.com/bitcoin/testnet"

  def get(path)
    res = Net::HTTP.get_response(uri(path))
    unless res.is_a?(Net::HTTPSuccess)
      puts "Error response \n"
    end
    JSON.parse(res.body)
  end

  def post(path, body)
    # res = Net::HTTP.post_form(push_uri(path), body)
    res = Net::HTTP.post_form(push_uri("push/transaction"), body)
    unless res.is_a?(Net::HTTPSuccess)
      puts "Error response \n"
    end
    JSON.parse(res.body)
  end

  private

  def uri(path)
    URI("#{TESTNET_API_URL}/#{path}")
  end

  def push_uri(path)
    URI("#{TESTNET_API_POST_URL}/#{path}")
  end
end
