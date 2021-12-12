# frozen_string_literal: true

class Builder
  include Bitcoin::Builder

  def initialize
    @stats = Stats.new
  end

  def pay_transaction(key_hash, addr_to, utxo, balance, amount, fee)
    key = Bitcoin::Key.new(key_hash[:priv], key_hash[:pub])

    build_tx do |t|
      utxo.each do |utxo_hash|
        # raw_prev_tx = @stats.tx(utxo_hash["txid"])
        # transformed_prev_tx = transform_format(raw_prev_tx, utxo_hash["vout"])
        # prev_tx = Bitcoin::P::Tx.from_hash(transformed_prev_tx)

        # puts utxo_hash["txid"]
        # puts @stats.tx(utxo_hash["txid"])["vout"][utxo_hash["vout"]]["scriptpubkey"]

        # binding.pry
        puts utxo_hash["txid"]
        a = Bitcoin::Script.from_string("76a914b81420a39f9bf5647a02d6e3af5a4932a4eae93888ac")
        # binding.pry
        # binding.pry
        # puts transformed_prev_tx["out"][utxo_hash["vout"]]["scriptPubKey"]
        # puts prev_tx.to_hash

        t.input do |i|
          # i.prev_out prev_tx
          i.prev_out utxo_hash["txid"]
          i.prev_out_index utxo_hash["vout"]
          i.prev_out_script = a.chunks.first
          # i.prev_out_script = @stats.tx(utxo_hash["txid"])["vout"][utxo_hash["vout"]]["scriptpubkey"]
          i.signature_key key
        end
      end

      t.output do |o|
        o.value amount
        o.script {|s| s.recipient addr_to }
      end

      t.output do |o|
        o.value balance - amount - fee
        o.script {|s| s.recipient key_hash[:addr] }
      end
    end
  end

  private

  def transform_format(tx, out_index)
    tx["in"] = tx.delete("vin")
    tx["out"] = tx.delete("vout")
    tx["lock_time"] = tx.delete("locktime")

    tx["in"].map do |input|
      input["previous_transaction_hash"] = input["prevout"]["scriptpubkey"] #?
      input["output_index"] = input["vout"]
      input["coinbase"] = input["is_coinbase"]
      input["scriptSig"] = input["scriptsig"]
    end

    tx["out"].map.with_index do |out, index|
      out["value"] = out["value"].to_s
      script = out.delete("scriptpubkey_asm")
      if index == out_index
        out["scriptPubKey"] = script.sub(" OP_PUSHBYTES_20 ", " ")
      else
        out["scriptPubKey"] = ""
      end
    end

    tx
  end
end
