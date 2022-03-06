# frozen_string_literal: true

class FileStructure
  # Provide a DSL to easily create file structure definitions.
  #
  # @example
  #   structure = FileStructure::DSL.eval do
  #     directory 'dir_a' do
  #       file 'file_a'
  #       symlink 'point_to_file_c', to: 'file_c_ref'
  #       directory 'dir_b' do
  #         file 'file_b'
  #         file 'file_c', ref: 'file_c_ref'
  #       end
  #     end
  #   end
  #   # => [{ type: :directory, name: 'dir_a', children: [ ... ] }]
  class DSL
    # @return [Hash] the resulting file structure definition
    attr_reader :structure

    # Return the file structure definition builded with the given block.
    #
    # @see structure
    def self.eval(&block)
      dsl = new
      dsl.instance_eval(&block)
      dsl.structure
    end

    def initialize
      @structure = []
    end

    # Add a file definition to the parent structure.
    #
    # @param name     [String]  the name of the file
    # @param content  [String]  the content of the file
    # @param ref      [String]  the reference to use for symlinks
    # @return         [Hash]    the created file definition
    def file(name, content: nil, ref: name)
      file = { type: :file, name: name }
      file[:content] = content if content
      file[:ref] = ref
      @structure << file and return file
    end

    # Add a symlink to the parent structure.
    #
    # @param name [String]  the name of the symlink
    # @param to   [String]  the reference of the file to point to
    # @return     [Hash]    the created symlink definition
    def symlink(name, to:)
      symlink = { type: :symlink, name: name, to: to }
      @structure << symlink and return symlink
    end

    # Add a directory to the parent structure.
    #
    # @param name [String]  the name of the directory
    # @param ref  [String]  the reference to use for symlinks
    # @return     [Hash]    the created directory definition
    def directory(name, ref: name, &block)
      dsl = self.class.new
      dsl.instance_eval(&block)
      children = dsl.structure
      directory = {
        type: :directory,
        name: name,
        children: children,
        ref: ref
      }
      @structure << directory and return directory
    end
  end
end
