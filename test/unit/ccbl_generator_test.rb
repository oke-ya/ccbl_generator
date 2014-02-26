require "test_helper"

class CcblGeneratorTest < Minitest::Unit::TestCase
  def setup
    @ccbl_generator = CcblGenerator.new(File.expand_path("../../fixtures/MainLayer.ccb"))
  end

  def test_generate
    @ccbl_generator.generate
  end
end
