require 'rspec'

require_relative '../../../../lib/admix/google_drive/access_token'

RSpec.describe AccessToken do

  before(:all) do
    @one_hour = 60 * 60
    @token_hash = {
        :access_token => 'an access token',
        :refresh_token => 'a refresh token',
        :expires_in => 3600,
        :user_email => 'a user_email'
    }
  end

  it 'returns true when the token has expired' do
    time_in_past = (Time.now - @one_hour).to_s
    access_token = AccessToken.new(@token_hash.merge({:expires_at => time_in_past}))

    expect(access_token.has_token_expired?).to eq true
  end

  it 'returns false when the token has not expired' do
    time_in_future = (Time.now + @one_hour).to_s
    access_token = AccessToken.new(@token_hash)

    expect(access_token.has_token_expired?).to eq false
  end

  it 'returns a hash that contains the class attributes' do
    expected_result = @token_hash.merge({:expires_at => (Time.now + @token_hash[:expires_in]).to_s})
    access_token = AccessToken.new(@token_hash)

    expect(access_token.to_hash).to eq expected_result
  end
end