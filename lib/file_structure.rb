# frozen_string_literal: true

require 'fileutils'
require_relative 'file_structure/contract'
require_relative 'file_structure/validator'
require_relative 'file_structure/version'

# Manage files, directories and links described with a file structure
# definition as a Ruby Hash. A valid file structure definition is an Array
# of Hashes with the following possible file definitions:
#
# rubocop:disable Layout/LineLength
# @example
#   { name: 'myfile', type: :file, content: 'abc', ref: 'fileref'} # :content and :ref are optional
#   { name: 'mydir' type: :directory, children: [<another valid file structure definition>], ref: 'dirref' } # :ref is optional
#   { name: 'mylink', type: :link, to: 'fileref' } # link to 'myfile' refereced earlier by 'fileref'
# rubocop:enable Layout/LineLength
class FileStructure
  attr_reader :structure, :mountpoint

  # @param structure [Array<Hash>] a valid file structure definition.
  # @raise [AssertionError] if the file structure is invalid
  def initialize(structure)
    Contract.assert(valid_file_structure?(structure), 'invalid file structure')

    @structure = structure
    @mountpoint = nil
  end

  # Effectively creates files and directories in the specified directory.
  #
  # @param dirname [String] the target directory
  # @raise [AssertionError] if the FileStructure is already mounted
  # @return void
  # @see unmount
  def mount(dirname)
    Contract.assert(!mounted?, 'file structure is already mounted')

    mountpoint = File.absolute_path(dirname)
    FileUtils.mkdir_p(mountpoint) unless Dir.exist?(mountpoint)
    begin
      create_file_structure(mountpoint, @structure)
    rescue StandardErrror => e
      FileUtils.rm_r(Dir.glob("#{mountpoint}/*")) # clear residuals
      raise e
    end
    @mountpoint = mountpoint
  end

  # Remove all files from the mountpoint.
  #
  # @return void
  # @see mount
  def unmount
    Contract.assert(mounted?, 'file structure is not mounted')

    FileUtils.rm_r(Dir.glob("#{@mountpoint}/*"))
    @mountpoint = nil
  end

  def mounted?
    !!@mountpoint
  end

  # Get the full path for a file in the mounted file structure.
  #
  # @example
  #   path_for(:foo, :bar, :file)
  #   # => "/path/to/mountpoint/foo/bar/file"
  #
  # @param args [Symbol, String Array<Symbol, String>] the recursive names to
  #   the desired file or directory
  # @return [String] the full path to the specified file/directory
  # @raise [AssertionError] if the file structure is not mounted
  def path_for(*args)
    Contract.assert(mounted?, 'file structure is not mounted')

    finder = [*args].flatten.map(&:to_sym)
    build_path(finder, @structure)
  end

  private

  def valid_file_structure?(structure)
    FileStructure::Validator.new(structure).valid?
  end

  # @param finder [Array] such as :foo, :bar
  # @param structure [Array] file structure definition
  # @param path [String] starting path (recursive accumulator)
  def build_path(finder, structure, path = @mountpoint)
    return path if finder.empty? || structure.nil?

    base = structure.find { |item| item[:name].to_s == finder.first.to_s }
    return nil if base.nil?

    build_path(
      finder[1..],
      base[:children],
      File.join(path, base[:name])
    )
  end

  # @param dirname [String] root directory
  # @param structure [Array] file structure definition
  # @param symlinks [Hash] current symlinks refs (recursive accumulator)
  def create_file_structure(dirname, structure, symlinks = {})
    structure.each do |element|
      path = File.join(File.absolute_path(dirname), element[:name])
      case element[:type]
      when :file
        File.write(path, element[:content])
        symlinks.merge!(element[:ref] => path) if element[:ref]
      when :symlink
        FileUtils.symlink(symlinks[element[:to]], path)
      when :directory
        FileUtils.mkdir(path)
        create_file_structure(path, element[:children], symlinks)
      end
    end
  end
end
