require 'google_drive'

class GoogleSheetHelper

  @current_document

  def initialize(access_token, spreadsheet_title, worksheet_title)
    @session = GoogleDrive.login_with_oauth(access_token)
    @spreadsheet_title = spreadsheet_title
    @worksheet_title = worksheet_title
  end

  def update_cfd_for_day_date_column!(cfd, mapping)
    worksheet = get_worksheet
    cfd.update('date' => Time.now.strftime("%m/%d/%Y"))
    cfd.update('day' => worksheet[worksheet.num_rows, mapping['day'].to_i].to_i + 1)
  end

  def write_data_to_worksheet_with_mapping(mingle_statistics, column_mapping)
    worksheet = get_worksheet
    the_last_empty_row = worksheet.num_rows + 1
    mingle_statistics.each do |card_type, card_count|
      col = column_mapping[card_type].to_i
      worksheet[the_last_empty_row, col] = card_count
    end
    worksheet.synchronize
  end

  def get_data_for_last_row_and_column(column_number)
    worksheet = get_worksheet
    the_last_empty_row = worksheet.num_rows
    worksheet[the_last_empty_row, column_number]
  end

  private
  def get_worksheet
    spreadsheet = @session.spreadsheet_by_title(@spreadsheet_title)
    all_worksheets = spreadsheet.worksheets
    all_worksheets.select{ |worksheet| worksheet.title == @worksheet_title }.first
  end

end