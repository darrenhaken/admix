require_relative '../../lib/admix/admix'
require_relative '../scheduler/scheduler_logger'

class AdmixScheduler

  CLASS_FILE_NAME = 'admix_scheduler'
  def self.run
    app = AdmixApp.new()
    app.start
    app.sync
  end

  def self.scheduler_log
    logger = SchedulerLogger.new()
    logger.clear_logs
    {
        :error => logger.log_err,
        :standard => logger.log_file
    }
  end

  def self.scheduler_command
    "ruby -r \"#{AdmixScheduler.file_path}/#{CLASS_FILE_NAME}\" -e \"AdmixScheduler.run\""
  end

  private
  def self.file_path
    File.expand_path('..', __FILE__)
  end

end
