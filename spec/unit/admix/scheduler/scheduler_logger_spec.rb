require 'rspec'

require_relative '../../../../lib/scheduler/scheduler_logger'

RSpec.describe SchedulerLogger do

  it 'returns the log file with full path' do
    logger = SchedulerLogger.new('log_file.log')
    expected_result = File.expand_path('../../../../../lib/scheduler/logs/log_file.log', __FILE__)

    expect(logger.log_file).to eq expected_result
  end

  it 'returns the error log file with full path' do
    logger = SchedulerLogger.new('error_log_file.log')
    expected_result = File.expand_path('../../../../../lib/scheduler/logs/error_log_file.log', __FILE__)

    expect(logger.log_file).to eq expected_result
  end

end