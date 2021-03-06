# frozen_string_literal: true

class FileStructure
  module Contract
    module_function

    class AssertionError < ArgumentError; end

    # @param expression [Boolean] The expression to evaluate
    # @param message [String] The message to attach to the raised error
    #
    # @raise [AssertionError] if the expression evaluates to false
    #
    # @api private
    def assert(expression, message = '')
      raise AssertionError, message unless expression
    end
  end
end
