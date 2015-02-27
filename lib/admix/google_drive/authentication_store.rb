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

  def save_credentials_in_file(auth_credentials, file)
    token_hash = {:access_token => auth_credentials.access_token,
                  :refresh_token => auth_credentials.refresh_token,
                  :expires_in => auth_credentials.expires_in,
                  :expires_at => auth_credentials.expires_at.to_s,
                  :user_email => auth_credentials.username}

    File.open(file, 'w+') do |f|
      f.write(JSON.pretty_generate(token_hash))
    end
    true
  end


end