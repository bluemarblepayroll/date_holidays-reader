# typed: true
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

# Use time from the standard library (instead of core) which has .strptime:
require 'time'

module DateHolidays
  module Reader
    # A holiday which includes a date, start and end times, name, and type.
    # Based on https://github.com/commenthol/date-holidays#holiday-object .
    #
    # The date is represented as a Ruby Date instance as it is the
    # holiday start date in the local time zone.
    #
    # Start and end times are represented as Time instances in UTC. Note that
    # New Year's day in the US has a start time of January 1st at 5 AM UTC as
    # Eastern Standard Time is five hours after UTC.
    class Holiday
      acts_as_hashable

      attr_reader :date, :start_time, :end_time, :name, :type, :note

      # rubocop:disable Metrics/ParameterLists
      # This cop defaults to five parameters which seems a little low for
      # keyword arguments. This is a value object which gets frozen after
      # initialization so I'd rather pass in everything as needed right away.
      def initialize(date:, start_time:, end_time:, name:, type:, substitute: false, note: nil)
        # rubocop:enable Metrics/ParameterLists
        @date = date.respond_to?(:to_date) ? date.to_date : Date.strptime(date, '%Y-%m-%d')
        @start_time = parse_time(start_time)
        @end_time = parse_time(end_time)
        @name = name
        @type = type.to_sym
        @substitute = substitute
        @note = note

        freeze
      end

      def substitute?
        @substitute
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      # I could cut down on those cops by iterating over instance variable and
      # using meta programming. However, that would obscure intent.
      def ==(other)
        other.is_a?(self.class) &&
          other.date == date &&
          other.start_time == start_time &&
          other.end_time == end_time &&
          other.name == name &&
          other.type == type &&
          other.substitute? == substitute? &&
          other.note == note
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      private

      def parse_time(time)
        # Example time string: "2018-01-01T05:00:00.000Z"
        time.is_a?(Time) ? time : Time.xmlschema(time)
      end
    end
  end
end

# For reference:
# Core Time: https://ruby-doc.org/core-2.3.6/Time.html
# Stdlib Time: https://ruby-doc.org/stdlib-2.3.8/libdoc/time/rdoc/Time.html
# Stdlib Date: http://ruby-doc.org/stdlib-2.3.8/libdoc/date/rdoc/Date.html
