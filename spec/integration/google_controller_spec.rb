require 'rspec'
require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../lib/admix/google_drive/access_token_manager'

def rescue_exception(&block)
  begin
    yield block
  rescue Exception
  end
end

RSpec.describe GoogleController do

  before(:all) do
    @random_auth_file = File.expand_path('../../assets/random_auth.json',__FILE__)
  end

  after(:all) do
    File.delete(@random_auth_file) if File.exists?(@random_auth_file)
  end

  before(:each) do
    allow_any_instance_of(AccessTokenManager).to receive(:authorization_uri).and_return('This should be authorization URI')

    allow_any_instance_of(GoogleController).to receive(:print)
    allow_any_instance_of(GoogleController).to receive(:gets).and_return("auth code")

    google_settings = GoogleClientSettings.new('clinet_id', 'client_secret', 'user_email','ss_title', 'ws_title')
    @controller = GoogleController.new(google_settings, @random_auth_file)
  end

  it 'Prints the authorisation uri when the access token is nil' do
    rescue_exception {@controller.setup_controller}

    expect(@controller).to have_received(:print).with("> Copy this URL to your browser to grant access to the application: \n")
    expect(@controller).to have_received(:print).with("\nThis should be authorization URI\n")
  end

  it 'prompts the user for authorization code when access token is nil' do
    rescue_exception {@controller.setup_controller}

    expect(@controller).to have_received(:print).with("> Paste authorisation code here: \n")
  end

  it 'takes user input as an authorisation code' do
    rescue_exception{@controller.setup_controller}

    expect(@controller).to have_received(:gets).exactly(1)
  end

  it 'passes the authorisation code to the AccessToken' do
    expect_any_instance_of(AccessTokenManager).to receive(:request_new_token).with("auth code")

    @controller.setup_controller
  end

  it 'does not prompts user for authorization code when access token is returned' do
    allow_any_instance_of(AccessTokenManager).to receive(:get_access_token).and_return('an access token')

    expect(@controller).to receive(:gets).never

    @controller.setup_controller
  end

  it 'Asks user to re-enter authorization code 3 times, then exist when AccessTokenAuthorizationError is raised' do
    allow_any_instance_of(AccessTokenManager).to receive(:request_new_token).and_raise(AccessTokenAuthorisationError.new(''))

    expect{@controller.setup_controller}.to raise_error(SystemExit)
    expect(@controller).to have_received(:print).with("\n> Authorisation fails Try again: \n").exactly(3).times
  end

  it 'shows friendly error message and exist the app when when AccessTokenClientError is raised when requesting new token' do
    allow_any_instance_of(AccessTokenManager).to receive(:request_new_token).and_raise(AccessTokenClientError.new('invalid_client'))

    expect{@controller.setup_controller}.to raise_error(SystemExit)
    expect(@controller).to have_received(:print).with("\ninvalid_client\n")
  end

  it 'shows friendly error message and exist the app when when AccessTokenClientError is raised when refreshing token' do
    allow_any_instance_of(AccessTokenManager).to receive(:get_access_token).and_raise(AccessTokenClientError.new('invalid_client'))

    expect{@controller.setup_controller}.to raise_error(SystemExit)
    expect(@controller).to have_received(:print).with("\ninvalid_client\n")
  end

end
