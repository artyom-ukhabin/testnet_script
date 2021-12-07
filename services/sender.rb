# frozen_string_literal: true

require 'cgi'

class Sender
  def initialize
    @stats = Stats.new
    @builder = Builder.new
    @client = Client.new
  end

  def pay(key_lines, addr_to, amount)
    # переделать на структуру ключа (из гема?)
    key_hash = key_hash(key_lines)

    balance = @stats.balance(key_hash[:addr])
    return unless check_balance(balance, amount)

    utxo_data = utxo(key_hash[:addr])
    fee = calculate_fee(key_lines, addr_to, amount)
    return unless check_fee(balance, amount, fee)

    tx = @builder.pay_transaction(key_hash, addr_to, utxo_data, balance, amount, fee)
    # a = tx.to_json
    puts tx.to_payload.bth
    # binding.pry
    push(tx)
  end

  private

  def push(tx)
    path = "tx"
    body = { "tx" => CGI.escape(tx.to_payload.bth) }
    @client.post(path, body)
  end


  def check_balance(balance, amount)
    return true if balance > amount
    puts "Unable to send money: balance is lower than sending amount:\n"
    puts "Balance: #{balance}\n"
    puts "Amount: #{amount}\n"
    false
  end

  def utxo(source_addr)
    utxo_data = @stats.utxo(source_addr)
    utxo_data.filter do |utxo|
      # вот тут еще другие транзакции? За ними надо идти? Чекнуть
      utxo["confirmed"] == true
      utxo["txid"]
    end
  end

  def calculate_fee(key_lines, addr_to, amount)
    # исправить на подсчет от размера
    10000 # пока что константа
  end

  def check_fee(balance, amount, fee)
    return true if balance > (amount + fee)
    puts "Unable to send money: balance is lower than sending amount:\n"
    puts "Balance: #{balance}\n"
    puts "Amount: #{amount}\n"
    puts "Fee: #{fee}\n"
    false
  end

  def key_hash(key_lines)
    {
      priv: key_lines[0],
      pub: key_lines[1],
      addr: key_lines[2],
    }
  end
end
