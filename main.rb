# frozen_string_literal: true

require "pry-byebug"
require "bitcoin"

require_relative "services/key_manager"
require_relative "services/sender"
require_relative "services/stats"
require_relative "services/client"
require_relative "services/builder"
require_relative "services/btc_formatter"

class Main
  def initialize
    @wallet = nil
    @key_manager = KeyManager.new
    @sender = Sender.new
    @stats = Stats.new
  end

  def run
    Bitcoin.network = :testnet3 # config?

    puts "\n"

    @wallet = @key_manager.load
    log_wallet_status(@wallet)

    loop do
      show_menu

      input = gets.chomp; puts "\n"

      case input
      when "1" then generate_key
      when "2" then get_balance
      when "3" then pay
      when "4" then break
      else repeat_user_input
      end
    end
  end

  private

  def log_wallet_status(wallet)
    !wallet.nil? ?
      (puts "Wallet is found, address: #{wallet.addr} \n\n") :
      (puts "Wallet is not found, generate a new one, please \n\n")
  end

  def show_menu
    puts "Choose operation: \n"
    puts "1: generate new key\n"
    puts "2: check balance \n"
    puts "3: send money \n"
    puts "4: exit \n\n"
  end

  def repeat_user_input
    puts "Repeat your input, please \n\n"
  end

  def generate_key
    unless @wallet.nil?
      puts "Address is already present: #{@wallet.addr}. Are you sure? y/n:"
      confirm = gets.chomp; puts "\n"
      return unless confirm == "y"
    end

    @wallet = @key_manager.generate
    puts "Key for testnet has been generated. \n"
    puts "Address is: #{@wallet.addr} \n\n"
  end

  def get_balance
    balance = @stats.balance(@wallet.addr)
    puts "balance is #{BtcFormatter.format(balance)} BTC \n\n"
  end

  def pay
    puts "Specify receiver address: "
    addr_to = gets.chomp
    puts "Specify amount in satoshi: "
    amount = gets.chomp.to_f; puts "\n"

    result = @sender.pay(@wallet, addr_to, amount)
    if result[:success]
      puts "\nCompleted succesfully, transaction id is: #{result[:idx]}\n\n"
    else
      puts "\n"
      puts "HTTP status: #{result[:status]}" if result[:status]
      puts result[:message] if result[:message]
      puts "\n\n"
    end
  end
end

Main.new.run
