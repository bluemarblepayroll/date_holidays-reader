# typed: false
# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

RSpec.describe DateHolidays::Reader::Config do
  describe 'countries' do
    it 'returns a hash with country code keys and country name values' do
      countries = described_class.countries
      expect(countries).to be_a Hash
      expect(countries['US']).to eq 'United States of America'
    end
  end

  describe 'os detection' do
    describe 'native Mac OS' do
      before do
        allow(OS).to receive(:osx?).and_return true
        allow(OS).to receive(:linux?).and_return false
        allow(OS).to receive(:bits).and_return 64
      end

      it { should be_native_mac }
      it { should_not be_native_linux }

      it 'only supports 64 bit Mac OS' do
        expect(OS).to receive(:bits).and_return 32

        should_not be_native_mac
        should_not be_native_linux
      end
    end

    describe 'native Linux' do
      before do
        allow(OS).to receive(:osx?).and_return false
        allow(OS).to receive(:linux?).and_return true
        allow(OS).to receive(:bits).and_return 64
      end

      it { should be_native_linux }
      it { should_not be_native_mac }

      it 'only supports 64 bit Linux' do
        expect(OS).to receive(:bits).and_return 32

        should_not be_native_mac
        should_not be_native_linux
      end
    end
  end

  it 'allows the user to specify the location of his or her node binary' do
    path = '/usr/bin/node'
    expect(described_class.new(node_path: path).node_path).to eq(path)
  end
end
