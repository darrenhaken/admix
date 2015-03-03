require 'rspec'

# These variables needs to be set for some tests to pass [The current variables are fake and won't make the test pass]
ENV['GOOGLE_EMAIL'] = 'admixmingle@gmail.com'
ENV['GOOGLE_REFRESH_TOKEN'] = '1/RLcvXpydxAQCe_xjklDtrJoaneNnokf8av_J9SQ24pN90RDknAdJa_sgfheVM0XT'
ENV['GOOGLE_CLIENT_SECRET'] = 'oSAoSvc0dxg4H-VTI3OBXLyV'
ENV['GOOGLE_CLIENT_ID'] = '157478480211-fqa6jd2lucmssqcjvpra07ih39u93etu.apps.googleusercontent.com'

RSpec.configure do |config|
  config.disable_monkey_patching!
end