# frozen_string_literal: true

class Stats
  BALANCE_KEY = "chain_stats.funded_txo_sum"

  def initialize
    @client = Client.new
  end

  # хэдеры для джсон запроса?
  # https://github.com/yegor256/sibit/blob/master/lib/sibit/json.rb
  def balance(address)
    address_data = @client.get(address_path(address))
    address_data.dig(*BALANCE_KEY.split("."))
  end

  def utxo(address)
    @client.get(utxo_path(address))
  end

  def tx(tx_id)
    @client.get(tx_path(tx_id))
  end

  private

  def address_path(address)
    "address/#{address}"
  end

  def utxo_path(address)
    "address/#{address}/utxo"
  end

  def tx_path(tx_id)
    "tx/#{tx_id}"
  end
end
