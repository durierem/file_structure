# frozen_string_literal: true

require 'fileutils'
require_relative 'file_structure/contract'
require_relative 'file_structure/dsl'
require_relative 'file_structure/validator'
require_relative 'file_structure/version'

class FileStructure
  include Contract

  # @return [Hash] the file structure definition
  attr_reader :structure

  # @return [String, nil] the current mountpoint
  attr_reader :mountpoint

  # Build a new {FileStructure} using the {FileStructure::DSL}.
  #
  # @example
  #   FileStructure.build do
  #     dir 'foo' do
  #       file 'bar'
  #     end
  #   end
  #
  # @see FileStructure::DSL
  # @return [FileStructure]
  def self.build(&block)
    new(FileStructure::DSL.eval(&block))
  end

  # @param structure [Array<Hash>] a valid file structure definition.
  # @raise [AssertionError] if the file structure is invalid
  def initialize(structure)
    assert(valid_file_structure?(structure), 'invalid file structure')

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
    assert(!mounted?, 'file structure is already mounted')

    mountpoint = File.absolute_path(dirname)
    FileUtils.mkdir_p(mountpoint) unless Dir.exist?(mountpoint)
    begin
      create_file_structure(mountpoint, @structure)
    rescue StandardError => e
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
    assert(mounted?, 'file structure is not mounted')

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
  # @return [String] the full path to the specified file/directory if found
  # @return [nil] if no file/directory has been found
  # @raise [AssertionError] if the file structure is not mounted
  def path_for(*args)
    assert(mounted?, 'file structure is not mounted')

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
  # @param symlinks [Hash<ref, path>] symlinks map (don't use directly)
  # @return void
  def create_file_structure(dirname, structure, symlinks = nil)
    symlinks = extract_symlinks_map(dirname, structure) if symlinks.nil?

    structure.each do |element|
      path = File.join(File.absolute_path(dirname), element[:name])
      case element[:type]
      when :file
        File.write(path, element[:content])
      when :symlink
        FileUtils.symlink(symlinks[element[:to]], path)
      when :directory
        FileUtils.mkdir(path)
        create_file_structure(path, element[:children], symlinks)
      end
    end
  end

  # @param dirname [String] root directory
  # @param structure [Array] file structure definition
  # @param result [Hash] recursive accumulator (don't use directly)
  # @return [Hash<ref, path>] the resulting symlinks map
  def extract_symlinks_map(dirname, structure, result = {})
    structure.each do |element|
      next unless element[:ref]

      path = File.join(File.absolute_path(dirname), element[:name])
      result[element[:ref]] = path

      next unless element[:type] == :directory

      extract_symlinks_map(dirname, element[:children], result)
    end
    result
  end
end
