# frozen_string_literal: true

class KeyManager
  KEY_FILENAME = "private_key"

  def load
    return unless File.file?(KEY_FILENAME)
    priv_key = File.read("private_key")
    Bitcoin::Key.new(priv_key)
  end

  def generate
    key = Bitcoin::Key.generate
    File.write("./private_key", "#{key.priv}")
    key
  end
end
