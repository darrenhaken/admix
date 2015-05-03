require 'date'
require 'holidays'

class BackfillDateCalculator

  DATE_FORMAT = "%d/%m/%Y"

  def initialize(start_date, end_date)
    @start_date = Date.parse(start_date, DATE_FORMAT)
    @end_date = Date.parse(end_date, DATE_FORMAT)
  end

  def dates_excluding_weekends_and_holidays
    days_in_range = (@start_date .. @end_date).to_a
    days_in_range = days_in_range.select do |day|
      is_day_a_weekday?(day) and not is_england_public_holiday?(day)
    end
    days_in_range.map{|day| day.strftime(DATE_FORMAT)}
  end

  private
  def is_day_a_weekday?(day)
    not (day.saturday? or day.sunday?)
  end

  def is_england_public_holiday?(day)
    day.holiday?(:gb_eng)
  end
end