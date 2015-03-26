class SchedulerLogger

  attr_reader :log_file, :log_err
  LOG_PATH = File.expand_path('../logs', __FILE__)

  def initialize(name_of_log_file = 'scheduler.log', name_of_err_file = 'admix_scheduler_err.log')
    @log_file = name_of_log_file
    @log_err = name_of_err_file
  end

  def log_file
    "#{LOG_PATH}/#{@log_file}"
  end

  def log_err
    "#{LOG_PATH}/#{@log_err}"
  end

  def clear_logs
    clean_file(@log_file)
    clean_file(@log_err)
  end

  private
  def clean_file(file)
    new_file_name = Time.now.strftime("%d_%m_%y__%H_%M_%S_#{file}")
    if File.exists?("#{LOG_PATH}/#{file}")
      File.rename("#{LOG_PATH}/#{file}", "#{LOG_PATH}/#{new_file_name}")
    end
    File.open("#{LOG_PATH}/#{file}", 'w+'){}
  end
end