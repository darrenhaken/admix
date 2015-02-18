require 'google/api_client'
require 'google_drive'
require 'json'

module GoogleDriveApiHelper

  CLIENT_SCOPE = 'https://www.googleapis.com/auth/drive'
  AUTH_URI = "https://accounts.google.com/o/oauth2/auth"
  TOKEN_URI =  "https://accounts.google.com/o/oauth2/token"

  class AuthenticationManagerForInstalledAppClient

    attr_reader :access_token

    def initialize(client_id, client_secret, authorization_file, user_email)
      client = Google::APIClient.new(:application_name =>"Admix", :application_version=>"0.3")
      @auth = client.authorization
      @auth.client_id = client_id
      @auth.client_secret = client_secret
      @auth.scope = CLIENT_SCOPE
      @auth.username = user_email
      @auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
      @authorization_file = authorization_file
    end

    def access_token
      if (not get_stored_credentials?) || @auth.refresh_token
        return nil unless perform_authentication?
      end

      if @auth.access_token || has_token_expired?
        refresh_token
      end

      @access_token = @auth.access_token
    end


    def perform_authentication?
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
        if authorization_retry < 2
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

    def has_token_expired?
      Time.now > @auth.expires_at
    end

    def refresh_token
      begin
        @auth.grant_type = "refresh_token"
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
        @auth.access_token = token_hash["access_token"]
        @auth.refresh_token = token_hash["refresh_token"]
        @auth.expires_in = token_hash["expires_in"]
        @auth.expires_at = Time.parse(token_hash["expires_at"])
        if @auth.username == token_hash['user_email']
          @auth.username = token_hash['user_email']
          return true
        end
      end
      false
    end
  end

  class GoogleDriveServiceAccountClient

    SERVICE_ACCOUNT_PKCS12_FILE = File.expand_path('../../assets/key.p12', __FILE__)

    CLIENT_EMAIL = "157478480211-bev4be6lh4762k893ir60uov75lqi8hn@developer.gserviceaccount.com"
    CLIENT_SECRET = "notasecret"

    def initialize(app_name, app_version)
      @client = Google::APIClient.new(:application_name => app_name,
                                      :application_version => app_version)
      @drive = @client.discovered_api('drive', 'v2')
    end

    def perform_authentication (user_email=nil)
      pkcs12_key = Google::APIClient::KeyUtils.load_from_pkcs12(SERVICE_ACCOUNT_PKCS12_FILE,
                                                                CLIENT_SECRET)

      if not user_email.nil?
        @client.authorization = Signet::OAuth2::Client.new(
            :token_credential_uri => TOKEN_URI,
            :audience => TOKEN_URI,
            :scope => CLIENT_SCOPE,
            :issuer => CLIENT_EMAIL,
            :sub => user_email,
            :signing_key => pkcs12_key)
      else
        @client.authorization = Signet::OAuth2::Client.new(
            :token_credential_uri => TOKEN_URI,
            :audience => TOKEN_URI,
            :scope => CLIENT_SCOPE,
            :issuer => CLIENT_EMAIL,
            :signing_key => pkcs12_key)
      end

      begin
        @client.authorization.fetch_access_token!
      rescue Signet::AuthorizationError
        return false
      end
      return true
    end

    def list_all_files_for_the_service_account
      result = Array.new
      page_token = nil
      begin
        parameters = {}
        if page_token.to_s != ''
          parameters['pageToken'] = page_token
        end
        api_result = @client.execute(
            :api_method => @drive.files.list,
            :parameters => parameters)
        if api_result.status == 200
          files = api_result.data
          result.concat(files.items)
          page_token = files.next_page_token
        else
          puts "An error occurred: #{result.data['error']['message']}"
          page_token = nil
        end
      end while page_token.to_s != ''
      result
    end

    def download_file(file)
      if file.download_url
        result = @client.execute(:uri => file.download_url)
        if result.status == 200
          return result.body
        else
          puts "An error occurred: #{result.data['error']['message']}"
          return nil
        end
      else
        return nil
      end
    end

    def update_file(id, title, mime_type, file_path)
      result = @client.execute(
          :api_method => @drive.files.get,
          :parameters => { 'fileId' => id})
      if result.status == 200
        file = result.data
        file.title = title
        file.mime_type = mime_type
        media = Google::APIClient::UploadIO.new(file_path, file.mime_type)
        result = @client.execute(
            :api_method => @drive.files.update,
            :body_object => file,
            :media => media,
            :parameters => { 'fileId' => id,
                             'uploadType' => 'multipart',
                             'newRevision' => true,
                             'alt' => 'json' })
        if result.status == 200
          return result.data
        end
      end
      return nil
    end
  end
end