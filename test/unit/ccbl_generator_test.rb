require "test_helper"


CcblGenerator.module_eval do
  def get_binding
    @binding
  end
end

class CcblGeneratorTest < Minitest::Unit::TestCase
  def setup
    @ccbl_generator = CcblGenerator.new(project_name: "test",
                                        path: File.expand_path("../../fixtures/MainLayer.ccb", __FILE__))
  end

  def test_generate_loader
    assert_match /__test__MainLayerLoader__/, @ccbl_generator.generate_loader(@ccbl_generator.get_binding)
  end

  def test_generate_header
    header = @ccbl_generator.generate_header(@ccbl_generator.get_binding)
    ['__test__MainLayer__',
     'LabelTTF* title;',
     'std::string myCustomPropertyString;'].each do |expect|
      assert_match Regexp.new(Regexp.quote(expect)), header
    end
  end

  def test_generate_body
    body = @ccbl_generator.generate_body(@ccbl_generator.get_binding)
    ['if (0 == strcmp(pMemberVariableName, "myCustomProperty"))',
     'else if (0 == strcmp(pMemberVariableName, "myCustomPropertyBool"))'].each do |expect|
      puts body
      assert_match Regexp.new(Regexp.quote(expect)), body
    end
  end
end
