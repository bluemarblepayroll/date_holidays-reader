# typed: false
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module DateHolidays
  module Reader
    # A communication bridge to the JavaScript process which houses the date-holidays node module.
    class JsBridge
      BIN_PATH = File.expand_path('../../../bin', __dir__).freeze

      JS_PROGRAM_PATH = File.expand_path(File.join(BIN_PATH, '/holidays-to-json.js')).freeze
      NODE_BIN_PATH = File.expand_path('../../../node_bin', __dir__).freeze
      private_constant :JS_PROGRAM_PATH, :NODE_BIN_PATH

      attr_reader :config, :debug

      # TODO: initialize with a configuration object for how to run the command
      def initialize(config = Config.default, debug: false)
        @config = config
        @debug = debug

        freeze
      end

      def extract(sub_cmd, *args)
        JSON.parse(get_output(holidays_to_json_command + [sub_cmd, *args]))
      end

      def get_output(args)
        args = Array(args)
        cmd_tokens_as_strings = args.map(&:to_s)
        output = nil

        print_command(cmd_tokens_as_strings) if debug

        IO.popen(cmd_tokens_as_strings, err: %i[child out]) { |cmd_io| output = cmd_io.read }
        output
      end

      private

      # Returns an array of strings containing the tokens to execute the
      # date-holidays wrapper depending on configuration.
      def holidays_to_json_command
        if config.node_path
          [config.node_path, JS_PROGRAM_PATH]
        elsif pre_compiled_program
          [File.join(NODE_BIN_PATH, pre_compiled_program)]
        else
          # Fallback: a node path has not been configured and there is no
          # pre-compiled program for this OS so fallback to the shebang line in
          # the JS file.
          [JS_PROGRAM_PATH]
        end
      end

      def pre_compiled_program
        if config.native_mac?
          'holidays-to-json-macos'
        elsif config.native_linux?
          'holidays-to-json-linux'
        end
      end

      def output_command(cmd_args)
        puts "#{self.class}: about to invoke: '#{cmd_args.join(' ')}'"
      end
    end
  end
end
