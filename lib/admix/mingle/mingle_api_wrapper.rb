
class MingleAPIWrapper

  def initialize(username, password, mingle_url, rest_client)
    @username = username
    @password = password
    @mingle_url = mingle_url
    @rest_client = rest_client
  end

  
  def load_cards_for_project(project_name)
    cards_url = full_rest_resource(project_name)
    @resource_response = @rest_client.get(cards_url)

    if @resource_response.code == 200
      return true
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