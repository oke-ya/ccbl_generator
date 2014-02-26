require "test_helper"

class CcblGeneratorTest < Minitest::Unit::TestCase
  def setup
    @ccbl_generator = CcblGenerator.new(project_name: "test",
                                        path: File.expand_path("../../fixtures/MainLayer.ccb", __FILE__))
  end

  def test_generate_loader
    assert_match /#ifndef __test__MainLayer__/, @ccbl_generator.generate_loader
  end
end
