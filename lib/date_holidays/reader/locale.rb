# typed: true
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module DateHolidays
  module Reader
    # Represents specific locale which contains holidays. This is the main
    # entry point into the gem.
    class Locale
      attr_reader :country, :js_bridge, :region, :state

      def initialize(country:, state: nil, region: nil, js_bridge: JsBridge.new)
        @country = country || raise(ArgumentError, 'a country is required')
        @state = state
        @region = region
        @js_bridge = js_bridge

        freeze
      end

      # Returns the holiday data as a hash exactly as returned from the
      # date-holiday node module.
      def raw_holidays(year, language: :en, types: Set.new)
        types = validate_and_convert_types_to_set(types)

        result = js_bridge.extract(:holidays, locale_selector, year, *lang_opts(language))
        type_filter(result, types)
      end

      # Returns DateHolidays::Reader::Holiday instances.
      def holidays(year, language: :en, types: Set.new)
        raw_holidays(year, language: language, types: types).map do |raw_holiday|
          Holiday.make(transform_raw_holiday(raw_holiday))
        end
      end

      def states(language = :en)
        js_bridge.extract(:states, locale_selector, *lang_opts(language))
      end

      def regions(language = :en)
        raise Caution::IllegalStateError, 'a state is required' unless state

        js_bridge.extract(:regions, locale_selector, *lang_opts(language))
      end

      def languages
        js_bridge.extract(:languages, locale_selector)
      end

      def time_zones
        js_bridge.extract(:time_zones, locale_selector)
      end

      private

      # More inforamtion about holiday types is available at
      # https://github.com/commenthol/date-holidays#types-of-holidays .
      HOLIDAY_TYPES = Set.new(%i[bank observance optional public school]).freeze
      SUPPORTED_HOLIDAY_ATTRIBUTES = Set.new(%w[date start end name type substitute note]).freeze
      private_constant :HOLIDAY_TYPES, :SUPPORTED_HOLIDAY_ATTRIBUTES

      def transform_raw_holiday(raw)
        # Note that this could instead be .slice under Ruby >= 2.5 or with Rails:
        clean_hash = raw.select { |key, _value| SUPPORTED_HOLIDAY_ATTRIBUTES.include?(key) }

        # Node date-holidays uses start and end keys. The "end" key does not play well with Ruby.
        # Also, the "_time" suffix adds clarity.
        clean_hash[:start_time] = clean_hash.delete('start')
        clean_hash[:end_time] = clean_hash.delete('end')

        clean_hash
      end

      def locale_selector
        [country, state, region].compact.join('.')
      end

      # Needed because of https://github.com/commenthol/date-holidays/issues/56
      # TODO: this has been fixed: let node filter by type
      def type_filter(raw_holidays, types)
        return raw_holidays if types.empty?

        raw_holidays.select { |hol| types.include?(hol['type'].to_sym) }
      end

      def validate_and_convert_types_to_set(types)
        types = types.is_a?(Set) ? types : Set.new(types)
        invalid_types = types.difference(HOLIDAY_TYPES)

        if invalid_types.any?
          error_msg = "invalid holiday type(s): #{invalid_types.to_a.join(', ')}"
          raise ArgumentError, error_msg
        end

        types
      end

      def lang_opts(language)
        language ? ['--lang', language.to_s] : []
      end
    end
  end
end
