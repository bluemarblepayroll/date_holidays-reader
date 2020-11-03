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
    # Tells the gem how to interact with Node and provides a list of countries.
    # See the configuration section of the Readme for more inforamtion.
    class Config
      SUPPORTED_CPU_BITS = 64
      private_constant :SUPPORTED_CPU_BITS

      class << self
        attr_reader :node_path
        attr_writer :default

        def node_path=(path)
          # Clear out the cached config when the node path changes:
          @default = nil
          @node_path = path
        end

        def default
          @default ||= new(node_path: node_path)
        end

        def countries
          JsBridge.new.extract(:countries)
        end
      end

      attr_reader :node_path

      def initialize(node_path: nil)
        @node_path = node_path

        freeze
      end

      def native_mac?
        OS.osx? && OS.bits == SUPPORTED_CPU_BITS
      end

      def native_linux?
        OS.linux? && OS.bits == SUPPORTED_CPU_BITS
      end
    end
  end
end
