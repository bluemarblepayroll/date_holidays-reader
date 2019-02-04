# frozen_string_literal: true

module DateHolidays
  module Reader
    # Tells the gem how to interact with Node and provides a list of countries.
    # See the configuration section of the Readme for more inforamtion.
    class Config
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
        OS.osx?
      end

      def native_linux?
        OS.linux?
      end
    end
  end
end
