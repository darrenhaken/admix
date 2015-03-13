class MingleSettings

  attr_reader :url, :username, :project_name, :password

  def initialize(username, password, url, project_name)
    @username = username
    @password = password
    @url = url
    @project_name = project_name
  end

  def self.SETTING_KEYS
    ['username', 'password', 'url', 'project_name']
  end
end