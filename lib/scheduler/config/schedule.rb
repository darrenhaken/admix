# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require_relative '../scheduler_logger'
require_relative '../../../lib/scheduler/admix_scheduler'

every :day, :at => '18:00' do
  command_to_execute = AdmixScheduler.scheduler_command
  log_output = AdmixScheduler.scheduler_log

  command command_to_execute, :output => log_output
end
