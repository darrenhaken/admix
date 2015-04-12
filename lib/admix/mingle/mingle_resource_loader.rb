
class MingleAuthenticationError < TypeError

  attr_reader :message

  def initialize(error_message)
    @message = error_message
  end

end

class MingleResourceLoader

  MQL_GET_RESOURCE_URI = "https://%s:%s@%s/api/v2/projects/%s/cards/execute_mql.xml"

  attr_reader :resource

  def initialize(username, password, mingle_url, rest_client)
    @username = username
    @password = password
    @mingle_url = mingle_url
    @rest_client = rest_client
  end

  def get(project_name, filter_by_mql)
    cards_url = full_rest_resource(project_name)

    begin
      return send_get_request(cards_url, filter_by_mql)
    rescue RestClient::Unauthorized => e
      raise MingleAuthenticationError.new("Authentication fails wrong username/password")
    end
  end

  def full_rest_resource(project_name)
    MQL_GET_RESOURCE_URI % [@username, @password, @mingle_url, project_name]
  end

  private
  def send_get_request(cards_url, filter_by_mql)
    params = build_request_params(filter_by_mql)
    response = @rest_client.get(cards_url, params)
    if response.code == 200
      @resource = response.body
      return response.body
    end
  end

  def build_request_params(filter_by_mql)
    { :params =>
          { :mql => filter_by_mql }
    }
  end

end