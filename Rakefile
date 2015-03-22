require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'
require_relative 'spec/spec_helper'

task :env_check do
  env_keys = %w(GOOGLE_EMAIL GOOGLE_REFRESH_TOKEN GOOGLE_CLIENT_SECRET GOOGLE_CLIENT_ID)
  env_keys.each do |key|
    if not ENV.has_key?(key) or ENV[key].nil?
      puts "Set the ENV value for '#{key}' in spec/spec_helper.rb"
      exit(-1)
    end
  end
end

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = Dir['spec/unit/*/**/*_spec.rb']
    t.verbose = false
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = Dir['spec/integration/*/**/*_spec.rb']
    t.verbose = false
  end

  RSpec::Core::RakeTask.new(:contract => :env_check) do |t|
    t.pattern = Dir.glob('spec/contract/**/*_spec.rb')
    t.verbose = false
  end
end
