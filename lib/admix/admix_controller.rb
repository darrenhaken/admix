require_relative '../../lib/admix/utils/settings'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/mingle_cfd_data_point_loader'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/cfd_filler_for_worksheet'
require_relative '../../lib/admix/utils/backfill_date_calculator'

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

  DATE_FORMAT = '%d/%m/%Y'

  def back_fill_cfd_reports
    dates_to_fill = dates_to_backfill

    dates_to_fill.each do |date|
      data_point = @cfd_data_loader.get_cfd_data_point_on_date(date)
      @data_filler.insert_cfd_data_point_for_date(data_point, Date.parse(date, DATE_FORMAT))
      puts "Filling: #{date}"
    end

    puts 'Committing changes'
    @data_filler.commit_changes
  end

  private
  def dates_to_backfill
    today = Date.today.strftime(DATE_FORMAT)
    date_calculator = BackfillDateCalculator.new(@settings.mingle_settings.cfd_start_date, today)
    date_calculator.dates_excluding_weekends_and_holidays
  end

end