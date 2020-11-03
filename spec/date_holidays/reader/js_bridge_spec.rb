# typed: false
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

RSpec.describe DateHolidays::Reader::JsBridge do
  it 'can be configured to use node directly' do
    node_config = DateHolidays::Reader::Config.new(node_path: 'node')
    subject = described_class.new(node_config)

    first_arg = nil

    io_stub = OpenStruct.new(read: '[]')
    expect(IO).to receive(:popen) { |arg| first_arg = arg.shift }.and_yield(io_stub)

    subject.extract('foo')

    expect(first_arg).to eq 'node'
  end
end
