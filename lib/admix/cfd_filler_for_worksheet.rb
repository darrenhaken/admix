require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_worksheet_wrapper'
require_relative '../../lib/admix/google_drive/cfd_data_point_to_column_mapper'

class CfdFillerForWorksheet

  def initialize(google_settings, auth_file)
    @settings = google_settings
    @auth_file = auth_file
    @google_controller = GoogleController.new(@settings, @auth_file)
    @google_controller.setup_controller
    @wrapper = GoogleWorksheetWrapper.new(@google_controller.access_token)
    @worksheet = @wrapper.get_worksheet_in_spreadsheet(@settings.worksheet_title, @settings.spreadsheet_title)
  end

  def insert_cfd_data_point_for_date(cfd_data_point, date)
    @cfd_data_point= cfd_data_point
    update_cfd_data_point_with_date_key(date)
    update_cfd_data_point_with_day_key
    @wrapper.write_data_to_last_row_using_mapping(@worksheet, @cfd_data_point, CfdDataPointToColumnMapper.mapping)
  end

  def commit_changes
    @wrapper.push_changes_to_google_drive
  end

  private
  def update_cfd_data_point_with_day_key
    day_column = CfdDataPointToColumnMapper.mapping['day']
    column_value = @wrapper.value_in_the_last_row_for_column(day_column)
    day_count = to_numeric(column_value) + 1
    @cfd_data_point.update('day' => day_count)
  end

  def to_numeric(value)
    Integer(value) rescue 0
  end


  def update_cfd_data_point_with_date_key(date)
    @cfd_data_point.update('date' => date.strftime("%d/%-m/%Y"))
  end

end