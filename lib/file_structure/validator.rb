# frozen_string_literal: true

class FileStructure
  # @private
  class Validator
    def initialize(structure)
      @structure = structure
    end

    def valid?
      valid_structure?(@structure)
    end

    private

    def valid_structure?(structure)
      return false unless structure.is_a?(Array)

      structure.all? do |elem|
        return false unless elem.is_a?(Hash)

        case elem[:type]
        when :file
          valid_file?(elem)
        when :symlink
          valid_symlink?(elem)
        when :directory
          valid_directory?(elem)
        else
          false
        end
      end
    end

    def valid_file?(element)
      attributes = %i[type name ref content]
      element.key?(:name) && element.each_key.all? do |key|
        attributes.include?(key)
      end
    end

    def valid_symlink?(element)
      attributes = %i[type name to]
      element.key?(:name) && element.key?(:to) && element.each_key.all? do |key|
        attributes.include?(key)
      end
    end

    def valid_directory?(element)
      attributes = %i[type name ref children]
      element.key?(:name) &&
        element.key?(:children) &&
        element.each_key { |key| attributes.include?(key) } &&
        valid_structure?(element[:children])
    end
  end
end
