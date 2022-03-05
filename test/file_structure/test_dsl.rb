# frozen_string_literal: true

require 'test_helper'

class DslSpec < Minitest::Spec
  before { @dsl = FileStructure::DSL.new }

  describe '.eval' do
    it 'returns the described file structure definition' do
      structure = FileStructure::DSL.eval do
        file 'file_a'
        symlink 'point_to_file_b', to: 'file_b'
        directory 'dir_a' do
          file 'file_b', content: 'hello'
          file 'file_c', ref: 'ref_file_c'
          directory 'dir_b', ref: 'ref_dir_b' do
            symlink 'i_point_to_file_c', to: 'ref_file_c'
          end
        end
      end
      _(structure).must_equal([
        { type: :file, name: 'file_a', ref: 'file_a' },
        { type: :symlink, name: 'point_to_file_b', to: 'file_b' },
        {
          type: :directory,
          name: 'dir_a',
          ref: 'dir_a',
          children: [
            { type: :file, name: 'file_b', content: 'hello', ref: 'file_b' },
            { type: :file, name: 'file_c', ref: 'ref_file_c' },
            {
              type: :directory,
              name: 'dir_b',
              ref: 'ref_dir_b',
              children: [
                { type: :symlink, name: 'i_point_to_file_c', to: 'ref_file_c' }
              ]
            }
          ]
        }
      ])
    end
  end

  describe '#file' do
    it 'adds a file definition to the parent structure' do
      @dsl.file('zarn', content: '#00ff00', ref: 'Zarn')
      _(@dsl.structure).must_equal([
        { type: :file, name: 'zarn', content: '#00ff00', ref: 'Zarn' }
      ])
    end

    it 'returns the file definition' do
      _(@dsl.file('zarn', content: '#00ff00', ref: 'Zarn')).must_equal(
        { type: :file, name: 'zarn', content: '#00ff00', ref: 'Zarn' }
      )
    end

    describe 'without content' do
      it 'does not set a content property' do
        @dsl.file('zarn', ref: 'Zarn')
        _(@dsl.structure).must_equal([
          { type: :file, name: 'zarn', ref: 'Zarn' }
        ])
      end
    end

    describe 'without ref' do
      it 'sets the ref equal to the name' do
        @dsl.file('zarn', content: '#00ff00')
        _(@dsl.structure).must_equal([
          { type: :file, name: 'zarn', content: '#00ff00', ref: 'zarn' }
        ])
      end
    end
  end

  describe '#symlink' do
    it 'adds a symlink definition to the parent structure' do
      @dsl.symlink('i_am_zarn', to: 'zarn')
      _(@dsl.structure).must_equal([
        { type: :symlink, name: 'i_am_zarn', to: 'zarn' }
      ])
    end

    it 'returns the symlink definition' do
      _(@dsl.symlink('i_am_zarn', to: 'zarn')).must_equal(
        { type: :symlink, name: 'i_am_zarn', to: 'zarn' }
      )
    end
  end

  describe '#directory' do
    it 'adds a directory definition to the parent structure' do
      @dsl.directory('zarn') { file 'elaina' }
      _(@dsl.structure).must_equal([{
        type: :directory,
        name: 'zarn',
        ref: 'zarn',
        children: [
          { type: :file, name: 'elaina', ref: 'elaina' }
        ]
      }])
    end

    it 'returns the directory definition' do
      _(@dsl.directory('zarn') { file 'elaina' }).must_equal({
        type: :directory,
        name: 'zarn',
        ref: 'zarn',
        children: [
          { type: :file, name: 'elaina', ref: 'elaina' }
        ]
      })
    end

    describe 'without ref' do
      it 'sets the ref equal to the name' do
        _(@dsl.directory('zarn') { nil }).must_equal(
          {
            type: :directory,
            name: 'zarn',
            ref: 'zarn',
            children: []
          }
        )
      end
    end
  end
end
