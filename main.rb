# frozen_string_literal: true

require "pry-byebug"
require "bitcoin"

require_relative "services/generator"
require_relative "services/receiver"
require_relative "services/sender"
require_relative "services/stats"
require_relative "services/client"
require_relative "services/builder"

class Main
  DESTINATION_ADDRESS = "tb1qaqt22ey88htyhe3m7tx3kw8jswxg8x54fsx3w2lry5j40n3s56yq4xj9ms"
  BTC_DELIMITER = 100000000.0

  def initialize(destination)
    @destination = destination
    @key = nil
    @sender = Sender.new
    @stats = Stats.new
  end

  def run
    Bitcoin.network = :testnet3
    key_lines = File.readlines("private_key").map(&:chomp)
    purse_address = key_lines[2]

    loop do
      show_menu

      input = gets.chomp
      puts "\n"

      case input
      when "1"
        unless purse_address.empty?
          puts "Address is already present: #{purse_address}. Are you sure? y/n:"
          confirm = gets.chomp
          puts "\n"
          generate_key if confirm == "y"
        else
          generate_key
        end
      when "2" then get_balance(purse_address)
      when "3"
        # puts "Specify receiver address: "
        # addr_to = gets.chomp
        addr_to = DESTINATION_ADDRESS
        # puts "Specify amount in satoshi: "
        # amount = gets.chomp.to_i
        amount = 20000
        pay(key_lines, addr_to, amount)
      when "4" then break
      when "5" then break
      else repeat_user_input
      end
    end
  end

  private

  def generate_key
    @key = Generator.call
    puts "Key for testnet has been generated. \n"
    puts "Address is: #{@key.addr} \n\n"
  end

  def get_balance(address)
    balance = @stats.balance(address)
    puts "balance is #{balance / BTC_DELIMITER} BTC \n\n"
  end

  def pay(key_lines, addr_to, amount)
    result = @sender.pay(key_lines, addr_to, amount)
    binding.pry
    puts "Completed succesfully, transaction id is: #{result["idx"]}"
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
end

destination = ARGV[0]
Main.new(destination).run
