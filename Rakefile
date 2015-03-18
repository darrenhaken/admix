require_relative 'spec/spec_helper'

require "bundler/gem_tasks"
require 'rake'
require 'rspec/core/rake_task'

task :env_check do
  env_keys = ['GOOGLE_EMAIL', 'GOOGLE_REFRESH_TOKEN', 'GOOGLE_CLIENT_SECRET', 'GOOGLE_CLIENT_ID']
  env_keys.each do | key|
    if not ENV.has_key?(key) or ENV[key].nil?
      puts "Set the ENV value for '#{key}' in spec/spec_helper.rb"
      exit(-1)
    end
  end
end

namespace 'unit' do
  RSpec::Core::RakeTask.new(:mingle)  do |t|
    t.pattern = Dir.glob('spec/admix/mingle/*_spec.rb')
    t.rspec_opts = '--format documentation'
  end

  RSpec::Core::RakeTask.new(:google_drive)  do |t|
    t.pattern = Dir.glob('spec/admix/google_drive/*_spec.rb')
    t.rspec_opts = '--format documentation'
  end

  RSpec::Core::RakeTask.new(:settings) do |t|
    t.pattern = Dir.glob('spec/admix/*_spec.rb')
    t.rspec_opts = '--format documentation'
  end

  RSpec::Core::RakeTask.new(:all) do |t|
    t.pattern = Dir.glob('spec/admix/**/*_spec.rb')
    t.rspec_opts = '--format documentation'
  end

end

namespace 'integration' do
  RSpec::Core::RakeTask.new(:all)  do |t|
    t.pattern = Dir.glob('spec/integration/**/*_spec.rb')
    t.rspec_opts = '--format documentation'
  end
  end

namespace 'contract' do
  RSpec::Core::RakeTask.new(:all => :env_check)  do |t|
    t.pattern = Dir.glob('spec/contract/**/*_spec.rb')
    t.rspec_opts = '--format documentation'
  end
end

RSpec::Core::RakeTask.new(:spec => :env_check) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation'
end


task :unit_mingle => 'unit:mingle'
task :unit_google_drive => 'unit:google_drive'
task :unit_settings => 'unit:settings'
task :unit_test => 'unit:all'

task :integration_test => 'integration:all'
task :contract_test => 'contract:all'
