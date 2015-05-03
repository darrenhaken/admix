require 'rspec'
require_relative '../../../../lib/admix/utils/backfill_date_calculator'

RSpec.describe BackfillDateCalculator do

  let(:start_date){'2015/01/10'}
  let(:end_date){'2015/01/20'}
  subject{BackfillDateCalculator.new(start_date, end_date)}

  it 'Generates a range of dates between two dates excluding weekends' do
    weekends_dates = %w(10/01/2015 11/01/2015 17/01/2015 18/01/2015)

    dates_range = subject.dates_excluding_weekends_and_holidays

    expect(dates_range).to_not include(*weekends_dates)
  end

  context 'exclude any England public holiday days' do
    let(:start_date){'2015/04/01'}
    let(:end_date){'2015/04/10'}

    it 'generates dates without public holidays and weekends' do
      weekends_dates = %w(04/04/2015 05/04/2015)
      public_holiday_dates = %w(03/04/2015 06/04/2015)
      exlucded_dates = weekends_dates + public_holiday_dates

      dates_range = subject.dates_excluding_weekends_and_holidays

      expect(dates_range).to_not include(*exlucded_dates)
    end
  end
end