require 'rspec'

require_relative '../../../../../lib/admix/mingle/mingle_query_language/mql_builder'
require_relative '../../../../../lib/admix/mingle/mingle_query_language/mql_card_property'
require_relative '../../../../../lib/admix/mingle/mingle_query_language/mql_clause'

RSpec.describe MQLBuilder do

  it 'Returns MQLBuilder, and statement set to "SELECT name, type"' do
    builder = MQLBuilder.select(MQLCardProperty.name.and(MQLCardProperty.type))

    expect(builder).to be_a MQLBuilder
    expect(builder.statement).to eq "SELECT name, type"
    end

  it 'Returns MQLBuilder, and statement set to "SELECT name, type WHERE Type is Story"' do
    builder = MQLBuilder.select(MQLCardProperty.name.and(MQLCardProperty.type)).where(MQLClause.type_is('Story'))

    expect(builder).to be_a MQLBuilder
    expect(builder.statement).to eq 'SELECT name, type WHERE Type is Story'
  end

  it 'Returns MQLBuilder, and statement set to "SELECT name, type AS OF "22/04/2015" WHERE Type is Story"' do
    builder = MQLBuilder.select(MQLCardProperty.name.and(MQLCardProperty.type)).as_of('22/03/2015').where(MQLClause.type_is('Story'))

    expect(builder).to be_a MQLBuilder
    expect(builder.statement).to eq 'SELECT name, type AS OF "22/03/2015" WHERE Type is Story'
  end
  
end