# typed: false
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

RSpec.describe DateHolidays::Reader::Locale do
  let(:gb) { described_class.new(country: :gb) }
  let(:us) { described_class.new(country: :us) }
  let(:gb_holidays) do
    fixture_path = File.expand_path('./gb_fixture.json', __dir__)
    holidays_json = JSON.parse(File.read(fixture_path))
    DateHolidays::Reader::Holiday.array(holidays_json)
  end

  describe 'holidays' do
    it 'retrieves basic UK holidays' do
      holidays2018 = gb.holidays(2018)

      expect(holidays2018.length).to eq(9)
      expect(holidays2018).to eq(gb_holidays)
    end

    it 'correctly assigns substitute days' do
      us2016 = us.holidays(2016)
      xmas_date = Date.parse('2016-12-25')
      day_after_xmas_date = Date.parse('2016-12-26')

      # Not a substitute
      xmas = us2016.find { |h| h.date == xmas_date }
      expect(xmas).not_to be_nil
      expect(xmas.substitute?).to eq false

      # Monday, 2016-12-26 was a substitute as Christmas occurred on a Sunday:
      xmas_substitute = us2016.find { |h| h.date == day_after_xmas_date }
      expect(xmas_substitute).not_to be_nil
      expect(xmas_substitute.substitute?).to eq true
    end

    it 'retrieves holidays for a specific state' do
      orangemens_day = DateHolidays::Reader::Holiday.new(
        date: '2018-07-12 00:00:00',
        start_time: '2018-07-11T23:00:00.000Z',
        end_time: '2018-07-12T23:00:00.000Z',
        name: 'Battle of the Boyne, Orangemen’s Day',
        type: 'public',
      )
      nothern_ireland = described_class.new(country: :gb, state: :nir)
      holidays2018 = nothern_ireland.holidays(2018)

      expect(holidays2018.length).to eq(13)
      expect(holidays2018).to include(orangemens_day)
    end

    it 'retrieves holidays for a specific state and region' do
      mardi_gras = DateHolidays::Reader::Holiday.new(
        date: '2019-03-05 00:00:00',
        start_time: '2019-03-05T06:00:00.000Z',
        end_time: '2019-03-06T06:00:00.000Z',
        name: 'Mardi Gras',
        type: 'public',
      )

      new_orleans = described_class.new(country: :us, state: :la, region: :no)
      holidays2019 = new_orleans.holidays(2019)

      expect(holidays2019.length).to eq(22)
      expect(holidays2019).to include(mardi_gras)
    end

    it 'retrieves holidays for a region for a country without states'

    it 'retrieves holidays in a specific language' do
      gb = described_class.new(country: :gb)
      expect(gb.holidays(2017, language: :es).first.name).to eq 'Año Nuevo'
    end

    describe 'holiday type' do
      it 'filters by a single type' do
        found_holidays = us.holidays(2018, types: [:optional])
        found_holiday_types = Set.new(found_holidays.map(&:type))

        expect(found_holiday_types).to eq Set.new([:optional])
      end

      it 'filters by a multiple types' do
        found_holidays = us.holidays(2018, types: %i[optional public])
        found_holiday_types = Set.new(found_holidays.map(&:type))

        expect(found_holiday_types).to eq Set.new(%i[optional public])
      end

      it 'raises an ArgumentError when passed an invalid type' do
        expect do
          us.holidays(2018, types: %i[public bogus bogus2])
        end.to raise_error ArgumentError, 'invalid holiday type(s): bogus, bogus2'
      end
    end

    it 'allows a timezone to be set'

    describe 'validation' do
      it 'requires a country' do
        expect do
          described_class.new(country: nil, state: :il)
        end.to raise_error ArgumentError, 'a country is required'
      end
    end
  end

  describe 'states' do
    it 'returns a hash with state abbreviation keys and state name values' do
      states = us.states
      expect(states).to be_a Hash
      expect(states.size).to eq 51 # includes DC but not Puerto Rico
      expect(states['IL']).to eq 'Illinois'
    end
  end

  describe 'regions' do
    it 'requires a state' do
      expect { us.regions }.to raise_error(Caution::IllegalStateError, 'a state is required')
    end

    it 'returns a hash with region abbreviation keys and region name values' do
      regions = described_class.new(country: :us, state: :ca).regions
      expect(regions).to be_a Hash
      expect(regions['LA']).to eq 'Los Angeles'
    end

    it 'returns a an empty hash when there are no regions' do
      locale_no_regions = described_class.new(country: :us, state: :dc)
      expect(locale_no_regions.regions).to eq({})
    end
  end

  describe 'languages' do
    it 'returns an array of languages supported in this locale' do
      switzerland = described_class.new(country: :ch)
      found_langs = switzerland.languages

      expect(found_langs).to be_a Array
      expect(Set.new(found_langs)).to eq Set.new(%w[en de-ch de fr it])
    end
  end

  describe 'time zones' do
    it 'returns an array of time zones in this locale' do
      found_zones = gb.time_zones

      expect(found_zones).to eq ['Europe/London']
    end
  end

  describe 'configuration' do
    let(:node_path) { 'node' }

    it 'can invoke node directly' do
      node_config = DateHolidays::Reader::Config.new(node_path: node_path)
      node_bridge = DateHolidays::Reader::JsBridge.new(node_config)
      subject = described_class.new(country: :gb, js_bridge: node_bridge)
      holidays2018 = subject.holidays(2018)

      expect(holidays2018.length).to eq(9)
      expect(holidays2018).to eq(gb_holidays)
    end

    it 'can be configured at the module level' do
      DateHolidays::Reader::Config.node_path = node_path
      expect(DateHolidays::Reader::Config.default.node_path).to eq node_path

      subject = described_class.new(country: :gb)
      holidays2018 = subject.holidays(2018)

      expect(holidays2018.length).to eq(9)
      expect(holidays2018).to eq(gb_holidays)
    end
  end
end
