# frozen_string_literal: true

require 'test_helper'

class TestFileStructure < Minitest::Spec
  include FileStructure::Contract

  before do
    @tmpdir = Dir.mktmpdir
    @fs = FileStructure.new([{ type: :file, name: 'file1' }])
  end

  after { FileUtils.remove_entry(@tmpdir) }

  describe '#initialize' do
    it 'does not have a mountpoint yet' do
      fs = FileStructure.new([{ type: :file, name: 'file1' }])
      _(fs.mountpoint).must_be_nil
    end
  end

  describe '#mount' do
    before do
      @fs = FileStructure.build do
        file 'file_1'
        directory 'dir_1' do
          symlink 'symlink_1', to: 'file_1'
        end
      end
    end

    describe 'when the file structure is already mounted' do
      before { @fs.mount(@tmpdir) }

      it 'raises an AssertionError' do
        _ { @fs.mount(@tmpdir) }.must_raise(AssertionError)
      end

      it 'does not change the mountpoint' do
        original_mountpoint = @fs.mountpoint
        _ { @fs.mount('idk') }
        _(@fs.mountpoint).must_equal original_mountpoint
      end
    end

    describe 'when the target directory is not empty' do
      before { FileUtils.touch(File.join(@tmpdir, 'existing_file')) }

      it 'raises an AssertionError' do
        _ { @fs.mount(@tmpdir) }.must_raise(AssertionError)
      end

      it 'does not mount' do
        _ { @fs.mount(@tmpdir) }
        _(@fs.mounted?).must_equal false
      end
    end

    it 'creates the desired files' do
      @fs.mount(@tmpdir)
      _(File.join(@tmpdir, 'file_1')).path_must_exist
      _(File.join(@tmpdir, 'dir_1')).path_must_exist
      _(File.join(@tmpdir, 'dir_1/symlink_1')).path_must_exist
    end

    it 'sets the mountpoint' do
      @fs.mount(@tmpdir)
      _(@fs.mountpoint).must_equal @tmpdir
    end

    it 'creates the mountpoint if it does not exist' do
      mountpoint = File.join(@tmpdir, rand.to_s[2..])
      @fs.mount(mountpoint)
      _(Dir.exist?(mountpoint)).must_equal true
    end
  end

  describe '#unmount' do
    describe 'when the file structure is not mounted' do
      it 'raises an AssertionError' do
        _ { @fs.unmount }.must_raise(AssertionError)
      end
    end

    describe 'when the file structure is mounted' do
      before { @fs.mount(@tmpdir) }

      it 'deletes all the files from the mountpoint' do
        @fs.unmount
        _(File.join(@tmpdir, @fs.structure.first[:name])).path_wont_exist
      end

      it 'unsets the mountpoint' do
        @fs.unmount
        _(@fs.mountpoint).must_be_nil
      end
    end
  end

  describe '#mounted?' do
    it 'returns true when the file structure is mounted' do
      @fs.mount(@tmpdir)
      _(@fs.mounted?).must_equal true
    end

    it 'returns false when the file structure is not mounted' do
      _(@fs.mounted?).must_equal false
    end
  end

  describe '#path_for' do
    before { @fs.mount(@tmpdir) }

    describe 'when the file does not exist' do
      it 'returns nil' do
        _(@fs.path_for('unknown')).must_be_nil
      end
    end

    it 'returns the desired path' do
      _(@fs.path_for('file1')).must_equal File.join(@fs.mountpoint, 'file1')
    end
  end
end
