require 'rspec'

require_relative '../../../../lib/admix/utils/config_error'
require_relative '../../../../lib/admix/utils/config_checker'

RSpec.describe ConfigChecker do

  it "raises ConfiError when the given config dir does not exist" do
    dir_does_not_exist = 'path/to/dir'
    config_checker = ConfigChecker.new(dir_does_not_exist, [])

    expect{config_checker.check_config_files}.to raise_error ConfigError
  end

  it "does not raise ConfiError when the given config dir exists" do
    dir_does_not_exist = Dir.pwd
    config_checker = ConfigChecker.new(dir_does_not_exist, [])

    expect{config_checker.check_config_files}.not_to raise_error
  end

  it "raises ConfiError when given files do not exist in the config dir" do
    dir_that_exists = File.expand_path('../', __FILE__)
    files_do_not_exist = ['random_file.text']
    config_checker = ConfigChecker.new(dir_that_exists, files_do_not_exist)

    expect{config_checker.check_config_files}.to raise_error ConfigError
  end

  it "does not raise ConfiError when given files exist in the config dir" do
    dir_that_exists = File.expand_path('../', __FILE__)
    files_that_exist = ['config_checker_spec.rb']
    config_checker = ConfigChecker.new(dir_that_exists, files_that_exist)

    expect{config_checker.check_config_files}.not_to raise_error
  end

end