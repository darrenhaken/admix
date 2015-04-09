require 'rspec'

require_relative '../../../../../lib/admix/mingle/mingle_query_language/mql_clause'

RSpec.describe MQLClause do

  it "returns MQLClause with 'Status is Dev' as its clasue" do
    mql_clause = MQLClause.status_is('Dev')

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq 'Status is Dev'
  end

  it "returns MQLClause with 'Status is not Dev' as its clasue" do
    mql_clause = MQLClause.status_is_not('Dev')

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq 'Status is not Dev'
  end

  it "surrounds the status in a single quotation if it is longer than one word " do
    mql_clause = MQLClause.status_is_not('Dev done')

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq "Status is not 'Dev done'"
  end

  it "returns MQLClause with 'Status is Dev OR Status is QA' as its clasue" do
    mql_clause = MQLClause.status_is('Dev').or(MQLClause.status_is('QA'))

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq 'Status is Dev OR Status is QA'
  end

  it "returns MQLClause with 'Status is Dev done OR Status is Next OR Status is QA' as its clasue" do
    mql_clause = MQLClause.status_is('Dev done').or(MQLClause.status_is('Next')).or(MQLClause.status_is('QA'))

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq "Status is 'Dev done' OR Status is Next OR Status is QA"
  end

  it "returns MQLClause with 'Type is Story' as its clause" do
    mql_clause = MQLClause.type_is('Story')

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq 'Type is Story'
  end

  it "returns MQLClause with 'Type is not Defect' as its clause" do
    mql_clause = MQLClause.type_is_not('Defect')

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq 'Type is not Defect'
  end

  it "surrounds the type in a single quotation if it is longer than one word " do
    mql_clause = MQLClause.type_is_not('Power Ups')

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq "Type is not 'Power Ups'"
  end

  it "returns MQLClause with 'Type is Story OR Type is Defect' as its clause" do
    mql_clause = MQLClause.type_is('Story').or(MQLClause.type_is('Defect'))

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq 'Type is Story OR Type is Defect'
  end

  it "returns MQLClause with '(Status is Dev) AND (Type is Defect)' as its clause" do
    mql_clause = MQLClause.status_is('Dev').and((MQLClause.type_is('Defect')))

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq '(Status is Dev) AND (Type is Defect)'
  end

  it "returns MQLClause with '(Status is Dev OR Status is Next) AND (Type is Defect)' as its clause" do
    mql_clause = MQLClause.status_is('Dev').or(MQLClause.status_is('Next')).and((MQLClause.type_is('Defect')))

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq '(Status is Dev OR Status is Next) AND (Type is Defect)'
  end

  it "returns MQLClause with 'Moved to production' > '10/01/2014' as its clause" do
    mql_clause = MQLClause.moved_to_is_larger_than_date('production', '10/01/2014')

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq "'Moved to production date' > '10/01/2014'"
  end

  it "returns MQLClause with 'Moved to production' > '10/01/2014 AND Type is Story' as its clause" do
    mql_clause = MQLClause.moved_to_is_larger_than_date('production', '10/01/2014').and(MQLClause.type_is('Story'))

    expect(mql_clause).to be_a MQLClause
    expect(mql_clause.clause).to eq "('Moved to production date' > '10/01/2014') AND (Type is Story)"
  end

end