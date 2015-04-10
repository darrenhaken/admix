require 'google_drive'

class GoogleWorksheetWrapper

  attr_reader :current_worksheet

  def initialize(access_token)
    @session = GoogleDrive.login_with_oauth(access_token)
  end

  def write_data_to_last_row_using_mapping(worksheet, data, column_mapping)
    @current_worksheet = worksheet
    the_last_empty_row = worksheet.num_rows + 1
    data.each do |data_key, data_value|
      col = column_mapping[data_key].to_i
      worksheet[the_last_empty_row, col] = data_value
    end
  end

  def push_changes_to_google_drive
    @current_worksheet.synchronize
  end

  def get_worksheet_in_spreadsheet(worksheet_title, spreadsheet_title)
    spreadsheet = @session.spreadsheet_by_title(spreadsheet_title)
    all_worksheets = spreadsheet.worksheets
    @current_worksheet = all_worksheets.select{ |worksheet| worksheet.title == worksheet_title }.first
  end

  def value_in_the_last_row_for_column(column_number)
    last_row = @current_worksheet.num_rows
    @current_worksheet[last_row, column_number]
  end
end