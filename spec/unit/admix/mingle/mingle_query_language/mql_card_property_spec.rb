require 'rspec'

require_relative '../../../../../lib/admix/mingle/mingle_query_language/mql_card_property'

RSpec.describe MQLCardProperty do

  it 'returns MQLCardProperty with property "name"' do
    mql_card_property = MQLCardProperty.name

    expect(mql_card_property).to be_a MQLCardProperty
    expect(mql_card_property.property).to eq 'name'
  end

  it 'returns MQLCardProperty with property "status"' do
    mql_card_property = MQLCardProperty.status

    expect(mql_card_property).to be_a MQLCardProperty
    expect(mql_card_property.property).to eq 'status'
  end

  it 'returns MQLCardProperty with property "COUNT(*)"' do
    mql_card_property = MQLCardProperty.count

    expect(mql_card_property).to be_a MQLCardProperty
    expect(mql_card_property.property).to eq 'COUNT(*)'
  end

  it 'returns MQLCardProperty with property "type"' do
    mql_card_property = MQLCardProperty.type

    expect(mql_card_property).to be_a MQLCardProperty
    expect(mql_card_property.property).to eq 'type'
  end

  it 'returns MQLCardProperty with property as "name, type"' do
    mql_card_property = MQLCardProperty.name.and(MQLCardProperty.type)

    expect(mql_card_property).to be_a MQLCardProperty
    expect(mql_card_property.property).to eq 'name, type'
  end

  it 'returns MQLCardProperty with property as "name, status, type"' do
    mql_card_property = MQLCardProperty.name.and(MQLCardProperty.status).and(MQLCardProperty.type)

    expect(mql_card_property).to be_a MQLCardProperty
    expect(mql_card_property.property).to eq 'name, status, type'
  end
end