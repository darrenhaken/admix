require 'google_drive'

class GoogleSheetHelper

  @current_document

  def initialize(access_token, spreadsheet_title, worksheet_title)
    @session = GoogleDrive.login_with_oauth(access_token)
    @spreadsheet_title = spreadsheet_title
    @worksheet_title = worksheet_title
  end

  def update_cfd_for_day_date_column!(cfd, mapping)
    ws = get_worksheet
    ws.synchronize()
    cfd.update('date' => Time.now.strftime("%m/%d/%Y"))
    cfd.update('day' => ws[ws.num_rows(), mapping['day'].to_i].to_i + 1)
  end

  def write_data_to_worksheet_with_mapping(mingle_statistics, column_mapping)
    ws = get_worksheet
    ws.synchronize()
    the_last_empty_row = ws.num_rows() + 1
    mingle_statistics.each do |k, v|
      col = column_mapping[k].to_i
      ws[the_last_empty_row, col] = v
    end
    ws.synchronize()
  end

  def get_data_for_last_row_and_column(column_number)
    ws = get_worksheet
    the_last_empty_row = ws.num_rows()
    ws[the_last_empty_row, column_number]
  end

  private
  def get_worksheet
    sp = @session.spreadsheet_by_title(@spreadsheet_title)
    all_ws = sp.worksheets()
    all_ws.select{|ws| ws.title == @worksheet_title}[0]
  end

end