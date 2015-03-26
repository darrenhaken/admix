require 'rspec'
require_relative '../../../../lib/scheduler/admix_scheduler'

RSpec.describe AdmixScheduler do

  it 'returns the command to run in crontab app' do
    path_to_file = File.expand_path('../../../../../lib/scheduler/admix_scheduler', __FILE__)
    expected_command = "ruby -r \"#{path_to_file}\" -e \"AdmixScheduler.run\""

    expect(AdmixScheduler.scheduler_command).to eq expected_command
  end
end