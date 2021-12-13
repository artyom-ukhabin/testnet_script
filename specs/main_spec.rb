require 'webmock/rspec'
require_relative '../main'

RSpec.describe Main do
  describe "#get_balance" do
    let(:wallet) { KeyManager.new.load }
    let(:balance_url) { "#{Client::TESTNET_API_URL}/address/#{wallet.addr}/utxo" }
    let(:expected_sat_balance) { 10000 }
    let(:expected_btc_balance) { 0.0001 }
    let(:utxo_response) do
      [{ "status" => { "confirmed" => true }, "value" => expected_sat_balance}].to_json
    end

    before do
      stub_request(:get, balance_url)
        .to_return(body: utxo_response, status: 200)
    end

    it "counts balance from utxo" do
      expect { Main.new.send(:get_balance) }.to output(
        "balance is #{expected_btc_balance} BTC \n\n"
      ).to_stdout
    end
  end
end
