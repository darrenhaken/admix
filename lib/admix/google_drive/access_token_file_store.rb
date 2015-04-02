require 'singleton'
require 'json'

class AccessTokenFileStore

  include Singleton

  def load_stored_access_token(file)
    if File.exists?(file)
      token_hash = JSON.parse(File.read(file))
      make_hash_keys_symbolic(token_hash)
    end
  end

  def store_access_token_hash_in_file(token_hash, file)
    File.open(file, 'w+') do |f|
      credentials_json = JSON.pretty_generate(token_hash)
      f.write(credentials_json)
    end
  end

  private
  def make_hash_keys_symbolic(token_hash)
    hash_with_symbolic_keys = {}
    token_hash.each do |k, v|
      hash_with_symbolic_keys[k.to_sym] = v
    end
    hash_with_symbolic_keys
  end
end