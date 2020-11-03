# typed: false
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#
require_relative 'js_bridge'

module DateHolidays
  module Reader
    VERSION = '1.0.3'

    # Used to retrieve further version information such as the underlying Node module version.
    class Version
      VERSION_PROGRAM_PATH = File.join(JsBridge::BIN_PATH, 'date-holidays-version.js').freeze
      private_constant :VERSION_PROGRAM_PATH

      class << self
        def node_module_version(config = Config.default)
          # When running via node, check to see what version the user has
          # installed. This could be different from what is in this gem's
          # yarn.lock.
          if config.node_path
            JsBridge.new(config).get_output(VERSION_PROGRAM_PATH).chomp
          else
            from_yarn_dot_lock
          end
        end

        private

        DATE_HOLIDAYS_MODULE_BEGIN = /\Adate-holidays@/.freeze
        VERSION_MATCHER = /\A  version "(.*?)"/.freeze
        YARN_DOT_LOCK_ERROR_MSG = 'unable to determine date-holidays node module version from ' \
                                  'yarn.lock'
        YARN_DOT_LOCK_PATH = File.expand_path('../../../yarn.lock', __dir__).freeze
        private_constant :DATE_HOLIDAYS_MODULE_BEGIN, :YARN_DOT_LOCK_ERROR_MSG, :YARN_DOT_LOCK_PATH

        # Note that yarn.lock does not use a standard format such as YAML or
        # JSON and no native parser is currently available in Ruby. This is
        # basic but it gets the job done.
        def from_yarn_dot_lock
          look_for_version = false

          File.new(YARN_DOT_LOCK_PATH).each do |line|
            if !look_for_version && line =~ DATE_HOLIDAYS_MODULE_BEGIN
              look_for_version = true
              next
            end

            found_version = extract_version(line) if look_for_version
            return found_version if found_version
          end

          raise Caution::IllegalStateError, YARN_DOT_LOCK_ERROR_MSG
        end

        def extract_version(line)
          line =~ VERSION_MATCHER && Regexp.last_match(1)
        end
      end
    end
  end
end
