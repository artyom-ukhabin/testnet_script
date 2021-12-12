# frozen_string_literal: true

class Builder
  include Bitcoin::Builder

  def initialize
    @stats = Stats.new
  end

  def pay_transaction(wallet:, addr_to:, utxo:, balance:, amount:, fee:)
    sig_script = sig_script(utxo)

    build_tx do |t|
      utxo.each do |utxo_hash|
        t.input do |i|
          i.prev_out utxo_hash["txid"]
          i.prev_out_index utxo_hash["vout"]
          i.prev_out_script sig_script
          i.signature_key wallet
        end
      end

      t.output do |o|
        o.value amount
        o.script {|s| s.recipient addr_to }
      end

      t.output do |o|
        o.value balance - amount - fee
        o.script {|s| s.recipient wallet.addr }
      end
    end
  end

  private

  # This script is constant for an address and its possible to get from the key itself.
  # 'Bit' lib in Python does this. However, I didn't spot this method in "bitcoin-ruby".
  def sig_script(utxo)
    first_utxo = utxo.first
    some_prev_tx = @stats.tx(first_utxo["txid"])
    sig_script_string = some_prev_tx["vout"][first_utxo["vout"]]["scriptpubkey"]
    Bitcoin::Script.from_string(sig_script_string).chunks.first
  end
end
