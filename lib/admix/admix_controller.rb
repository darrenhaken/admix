require_relative '../../lib/admix/utils/settings'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/mingle_cfd_data_point_loader'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/cfd_filler_for_worksheet'

class AdmixController

  PATH_TO_FILE = File.expand_path('../../assets/auth_details.json',__FILE__)

  def start_app
    @settings = Settings.instance

    begin
      @settings.load_application_settings
    rescue AdmixSettingsError => e
      print("Error: #{e.error_message}\n")
      exit(-1)
    end

    @cfd_data_loader = MingleCfdDataPointLoader.new(@settings.mingle_settings, @settings.filter_file)
    @data_filler = CfdFillerForWorksheet.new(@settings.google_client_settings, PATH_TO_FILE)

    print("\nYou've authorized access to the application successfully!\n")
  end

  def fill_today_report
    cfd_data_point = @cfd_data_loader.get_today_cfd_data_point
    @data_filler.insert_cfd_data_point_for_date(cfd_data_point, Time.now)
    @data_filler.commit_changes
  end

  DATE_FORMAT = "%d/%m/%Y"

  def back_fill_cfd_reports
    dates_to_fill = generate_dates_between_today_and(@settings.mingle_settings.cfd_start_date)
    dates_to_fill.each { |date|
      data_point = @cfd_data_loader.get_cfd_data_point_on_date(date.strftime(DATE_FORMAT))
      @data_filler.insert_cfd_data_point_for_date(data_point, date)
      puts "Filling: #{date}"
    }
    puts "Committing changes"
    @data_filler.commit_changes
  end

  private
  def generate_dates_between_today_and(start_date)
    current_day = Date.today
    start_day = Date.parse(start_date, DATE_FORMAT)
    days_in_range = (start_day .. current_day).to_a
    days_in_range.select{|day| is_day_a_weekday?(day)}
  end

  def is_day_a_weekday?(day)
    not (day.saturday? or day.sunday?)
  end

end