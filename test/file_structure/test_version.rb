# frozen_string_literal: true

require 'test_helper'

class VersionSpec < Minitest::Spec
  it 'has a version number' do
    refute_nil(::FileStructure::VERSION)
  end
end
