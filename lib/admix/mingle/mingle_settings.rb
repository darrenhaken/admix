class MingleSettings

  attr_reader :url, :username, :project_name, :password, :cfd_start_date

  def initialize(username, password, url, project_name, cfd_start_date)
    @username = username
    @password = password
    @url = url
    @project_name = project_name
    @cfd_start_date = cfd_start_date
  end

  def self.SETTING_KEYS
    ['username', 'password', 'url', 'project_name', 'cfd_start_date']
  end
end