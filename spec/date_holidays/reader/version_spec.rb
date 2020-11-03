# typed: false
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

RSpec.describe DateHolidays::Reader::Version do
  describe 'node module version' do
    it 'comes from yarn.lock run running from binaries' do
      expect(described_class.node_module_version).to eq('1.6.1')
    end

    it 'comes from the installed date-holidays module when running from Node' do
      node_config = DateHolidays::Reader::Config.new(node_path: 'node')
      expect(described_class.node_module_version(node_config)).to eq('1.6.1')
    end
  end
end
