require 'google/api_client'

#TODO refactor the whole class, and use injuction for some variables.
module ServiceAccountClientApp
  class AuthenticationManager

    CLIENT_SCOPE = 'https://www.googleapis.com/auth/drive'
    AUTH_URI = "https://accounts.google.com/o/oauth2/auth"
    TOKEN_URI =  "https://accounts.google.com/o/oauth2/token"

    # probably these should be init params
    SERVICE_ACCOUNT_PKCS12_FILE = File.expand_path('../../../assets/key.p12', __FILE__)
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
      true
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
        nil
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
      nil
    end
  end
end