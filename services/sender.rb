# frozen_string_literal: true

require 'cgi'

class Sender
  DEFAULT_FEE = 10000

  def initialize
    @stats = Stats.new
    @builder = Builder.new
    @client = Client.new
  end

  def pay(wallet, addr_to, amount)
    utxo_data = @stats.confirmed_utxo(wallet.addr)

    balance = @stats.balance(wallet.addr)
    fee = calculate_fee(utxo_data)

    return { success: false, message: "Unable to pay" } unless able_to_pay?(balance, amount, fee)

    tx = @builder.pay_transaction(
      wallet: wallet,
      addr_to: addr_to,
      utxo: utxo_data,
      balance: balance,
      amount: amount,
      fee: fee,
    )
    push(tx)
  end

  private

  # fee =~ transaction size
  # transaction size =~ inputs x outputs; outputs = 2 -> destination + self
  # => fee =~ transaction size =~ inputs
  def calculate_fee(utxo_data)
    DEFAULT_FEE * utxo_data.length
  end

  def able_to_pay?(balance, amount, fee)
    return false unless check_balance(balance, amount)
    check_fee(balance, amount, fee)
  end

  def check_balance(balance, amount)
    return true if balance > amount
    puts "Unable to send money: balance is lower than sending amount:\n"
    puts "Balance: #{BtcFormatter.format(balance)}\n"
    puts "Amount: #{BtcFormatter.format(amount)}\n"
    false
  end

  def check_fee(balance, amount, fee)
    return true if balance > (amount + fee)
    puts "Unable to send money: balance is lower than sending amount:\n"
    puts "Balance: #{BtcFormatter.format(balance)}\n"
    puts "Amount: #{BtcFormatter.format(amount)}\n"
    puts "Fee: #{BtcFormatter.format(fee)}\n"
    false
  end

  def push(tx)
    path = "push/transaction"
    body = { data: CGI.escape(tx.to_payload.bth) }
    result = @client.post(path, body)
    result[:success] ?
      { success: true, idx: result[:response]["data"]["transaction_hash"] } :
      { success: false, status: result[:response].status, message: result[:response].body }
  end
end
