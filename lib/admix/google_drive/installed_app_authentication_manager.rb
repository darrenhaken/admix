require "google/api_client"
require 'json'

module InstalledApplication
  class AuthenticationManager

    CLIENT_SCOPE = 'https://www.googleapis.com/auth/drive'
    MAX_NUM_OF_AUTH_RETRY = 3

    attr_reader :access_token

    def initialize(client_id, client_secret, authorization_file, user_email)
      client = Google::APIClient.new(:application_name =>'Admix', :application_version=>'0.3')
      @auth = client.authorization
      @auth.client_id = client_id
      @auth.client_secret = client_secret
      @auth.scope = CLIENT_SCOPE
      @auth.username = user_email
      @auth.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      @authorization_file = authorization_file
    end

    def access_token()
      if (not get_stored_credentials?) || @auth.refresh_token.nil?
        return nil unless perform_authentication?
      end

      if @auth.access_token.nil? || has_token_expired?
        refresh_token
      end

      @access_token = @auth.access_token
    end


    def perform_authentication?()
      @auth.grant_type = nil
      authorization_retry = 0
      begin
        print("1. Open this page:\n%s\n\n" % @auth.authorization_uri)
        print("\n2. Enter the authorization code shown in the page: ")
        @auth.code = gets.chomp
        @auth.fetch_access_token!
        save_authorization_file
        true
      rescue Signet::AuthorizationError
        print("\n (Authorisation failed) Authorisation code has been used previously.\n")
        if authorization_retry < MAX_NUM_OF_AUTH_RETRY
          authorization_retry += 1
          retry
        end
        print("\n Authorisation failed 3 times.\n")
        @auth.access_token = nil
        false
      rescue ArgumentError
        print("\n Authorisation failed.\n")
        @auth.access_token = nil
        false
      end
    end

    private

    def has_token_expired?()
      Time.now > @auth.expires_at
    end

    def refresh_token()
      begin
        @auth.grant_type = 'refresh_token'
        @auth.fetch_access_token!
        @auth.expires_at = Time.now + @auth.expires_in
        save_authorization_file
        true
      rescue Signet::AuthorizationError
        perform_authentication?
      end
    end

    def save_authorization_file()
      token_hash = {:access_token => @auth.access_token,
                    :refresh_token => @auth.refresh_token,
                    :expires_in => @auth.expires_in,
                    :expires_at => @auth.expires_at.to_s,
                    :user_email => @auth.username}

      File.open(@authorization_file, 'w+') do |f|
        f.write(JSON.pretty_generate(token_hash))
      end
    end

    def get_stored_credentials?()
      if File.exists?(@authorization_file)
        file = File.read(@authorization_file)
        token_hash = JSON.parse(file)
        @auth.access_token = token_hash['access_token']
        @auth.refresh_token = token_hash['refresh_token']
        @auth.expires_in = token_hash['expires_in']
        @auth.expires_at = Time.parse(token_hash['expires_at'])
        if @auth.username == token_hash['user_email']
          @auth.username = token_hash['user_email']
          return true
        end
      end
      false
    end
  end
end