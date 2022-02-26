# frozen_string_literal: true

require 'test_helper'

class ValidatorSpec < Minitest::Spec
  describe '#valid?' do
    describe 'when the given structure is invalid' do
      it 'returns false with nil' do
        validator = FileStructure::Validator.new(nil)
        _(validator.valid?).must_equal false
      end

      it 'returns false with invalid types' do
        validator = FileStructure::Validator.new([
          { type: :unknown, name: 'foo' }
        ])
        _(validator.valid?).must_equal false
      end

      it 'returns false without names' do
        validator = FileStructure::Validator.new([
          { type: :file, name: 'foo' },
          { type: :file }
        ])
        _(validator.valid?).must_equal false
      end

      it 'returns false without children' do
        validator = FileStructure::Validator.new([
          { type: :directory, name: 'foo' }
        ])
        _(validator.valid?).must_equal false
      end
    end

    describe 'when the expression is valid' do
      it 'returns true' do
        validator = FileStructure::Validator.new([
          { type: :file, name: 'file1' },
          {
            type: :directory,
            name: 'dir1',
            children: [
              {
                type: :directory,
                name: 'dir2',
                children: [
                  {
                    type: :file,
                    name: 'file2',
                    ref: 'ref_file2',
                    content: 'abc'
                  }
                ]
              },
              { type: :file, name: 'file3' },
              { type: :symlink, name: 'link_to_file2', to: 'ref_file2' }
            ]
          }
        ])
        _(validator.valid?).must_equal true
      end
    end
  end
end
