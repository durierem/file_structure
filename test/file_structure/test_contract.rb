# frozen_string_literal: true

require 'test_helper'

class ContractSpec < Minitest::Spec
  describe '.assert' do
    describe 'when the expression is falsey' do
      it 'raises Contract::AssertionError' do
        _ { FileStructure::Contract.assert(false) }.must_raise(
          FileStructure::Contract::AssertionError
        )
      end
    end

    describe 'when the expression is truthy' do
      it 'does not raise Contract::AssertionError' do
        _ { FileStructure::Contract.assert(true) }.must_be_silent
      end
    end
  end
end
