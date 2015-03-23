require 'singleton'
require 'json'

class AuthenticationStore

  include Singleton

  def load_stored_credentials(file)
    if File.exists?(file)
      token_hash = JSON.parse(File.read(file))
      sym_token_hash = {}
      token_hash.each do |k, v|
        sym_token_hash[k.to_sym] = v
      end
      sym_token_hash
    end
  end

  def save_credentials_in_file(credentials_hash, file)
    File.open(file, 'w+') do |f|
      f.write(JSON.pretty_generate(credentials_hash))
    end
    true
  end


end