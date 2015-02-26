
class MingleAuthenticationError < TypeError

  attr_reader :message

  def initialize(error_message)
    @message = error_message
  end

end

class MingleResourceLoader

  attr_reader :resource

  def initialize(username, password, mingle_url, rest_client)
    @username = username
    @password = password
    @mingle_url = mingle_url
    @rest_client = rest_client
  end

  def resource
    @resource
  end

  def load_cards_for_project(project_name, filter_by_mql)
    cards_url = full_rest_resource(project_name)
    response = @rest_client.get(cards_url, {:params => {:mql=>filter_by_mql}})

    if response.code == 200
      @resource = response.body
      return true
    elsif response.code == 401
      raise MingleAuthenticationError.new("Authentication fails wrong username/password")
    end
    false
  end

  def full_rest_resource(project_name)
    "https://%s:%s@%s/api/v2/projects/%s/cards/execute_mql.xml" % [@username, @password, @mingle_url, project_name]
  end

end