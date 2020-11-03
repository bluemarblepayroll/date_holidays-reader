# typed: strict
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'acts_as_hashable'
require 'caution'
require 'json'
require 'os'

require_relative 'reader/config'
require_relative 'reader/holiday'
require_relative 'reader/js_bridge'
require_relative 'reader/locale'
require_relative 'reader/version'

module DateHolidays
  # Defines the outermost module for the gem.
  module Reader
    # Your code goes here...
  end
end
