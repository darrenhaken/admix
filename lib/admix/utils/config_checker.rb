require_relative 'config_error'

class ConfigChecker

  def initialize(config_dir, config_files_names)
    @config_dir = config_dir
    @config_files_names = config_files_names
  end

  def check_config_files
    unless Dir.exists?(@config_dir)
      err_msg = "The config directory does not exist.\nMake sure #{@config_dir} exists, and contains the settings files."
      raise ConfigError.new(err_msg)
    end

    @config_files_names.each do |file_name|
      unless File.exists?("#{@config_dir}/#{file_name}")
        err_msg = "#{file_name} does not exists. Make sure it is in #{@config_dir}"
        raise ConfigError.new(err_msg)
      end
    end
  end

end