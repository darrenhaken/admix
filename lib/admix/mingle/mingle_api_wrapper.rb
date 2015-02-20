
class MingleAPIAuthenticationError < TypeError

  attr_reader :message

  def initialize(error_message)
    @message = error_message
  end

end

class MingleAPIWrapper

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

  def get_cards_for_project(project_name, filter_by_mql=nil)
    cards_url = full_rest_resource(project_name)
    if filter_by_mql
      response = @rest_client.get(cards_url, {:params => {:mql=>filter_by_mql}})
    else
      response = @rest_client.get(cards_url)
    end

    if response.code == 200
      @resource = response.body
      return true
    elsif response.code == 401
      raise MingleAPIAuthenticationError.new("Authentication fails Wrong username/password")
    end
    false
  end

  def full_rest_resource(project_name=nil)
    if project_name
      return "https://%s:%s@%s/api/v2/projects/%s/cards.xml" %
                           [@username, @password, @mingle_url, project_name]
    end

    "https://%s:%s@%s/api/v2/projects.xml" % [@username, @password, @mingle_url]
  end

end