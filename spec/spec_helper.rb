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