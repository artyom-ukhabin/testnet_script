# frozen_string_literal: true

class Generator
  class << self
    def call
      key = Bitcoin::Key.generate
      File.write("./private_key", "#{key.priv}\n#{key.pub}\n#{key.addr}")
      key
    end
  end
end
