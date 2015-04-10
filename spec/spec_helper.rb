require 'rspec'

# These variables needs to be set for some tests to pass [The current variables are fake and won't make the test pass]
# To generate ENV['GOOGLE_REFRESH_TOKEN'] use the authorization_url_presenter.rb under script dir
ENV['GOOGLE_EMAIL'] = nil
ENV['GOOGLE_REFRESH_TOKEN'] = nil
ENV['GOOGLE_CLIENT_SECRET'] = nil
ENV['GOOGLE_CLIENT_ID'] = nil

RSpec.configure do |config|
  config.disable_monkey_patching!
end

def generate_auth_file
  file = File.expand_path('../assets/DO_NOT_OPEN_OR_CHANGE_ME.json', __FILE__)
  token_hash = {:access_token => nil,
                :refresh_token => ENV['GOOGLE_REFRESH_TOKEN'],
                :expires_in => 3600,
                :expires_at => (Time.now - (7200)).to_s,
                :user_email => ENV['GOOGLE_EMAIL']
  }

  File.open(file, 'w+') do |f|
    f.write(JSON.pretty_generate(token_hash))
  end
  file
end