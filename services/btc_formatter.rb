# frozen_string_literal: true

class BtcFormatter
  BTC_DELIMITER = (10**8).to_f

  class << self
    def format(btc_amount)
      ("%.8f" % (btc_amount / BTC_DELIMITER)).sub(/\.?0*$/, "")
    end
  end
end
