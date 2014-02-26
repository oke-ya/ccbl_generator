require "test_helper"

class CcblGeneratorTest < Minitest::Unit::TestCase
  def setup
    @ccbl_generator = CcblGenerator.new(project_name: "test",
                                        path: File.expand_path("../../fixtures/MainLayer.ccb", __FILE__))
  end

  def test_generate_loader
    assert_match /__test__MainLayerLoader__/, @ccbl_generator.generate_loader
  end

  def test_generate_header
    header = @ccbl_generator.generate_header
    assert_match /__test__MainLayer__/, header
    assert_match /cocos2d::LabelTTF\* title;/, header
  end
end
