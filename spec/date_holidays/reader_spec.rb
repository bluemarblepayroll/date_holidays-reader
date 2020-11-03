# typed: false
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

RSpec.describe DateHolidays::Reader do
  it 'has a version number' do
    expect(DateHolidays::Reader::VERSION).not_to be nil
  end
end
