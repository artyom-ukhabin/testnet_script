# frozen_string_literal: true

class Stats
  def initialize
    @client = Client.new
  end

  def balance(address)
    utxo = confirmed_utxo(address)
    utxo.reduce(0) { |result, utxo| result + utxo["value"] }
  end

  def confirmed_utxo(address)
    utxo(address).filter { |utxo| utxo["status"]["confirmed"] }
  end

  def utxo(address)
    @client.get(utxo_path(address))[:response]
  end

  def tx(tx_id)
    @client.get(tx_path(tx_id))[:response]
  end

  private

  def utxo_path(address)
    "address/#{address}/utxo"
  end

  def tx_path(tx_id)
    "tx/#{tx_id}"
  end
end
