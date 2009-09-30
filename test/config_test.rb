require "test_helper"
require "test/unit"

class TestJestureConfig < Test::Unit::TestCase
  def test_config
    conf = Jesture::Config.new(File.join(File.dirname(__FILE__), "fixtures", "jestures.rb"))
    assert_not_nil(conf.jestures[:fight])
    assert_not_nil(conf.combos[:foo])
  end
  
  def test_parse_element_parses_string
    assert_equal([
        {:char_key => Jesture::KEYMAP[:m]}, 
        {:char_key => Jesture::KEYMAP[:o]}],
      Jesture::Config.parse_element("mo"))
  end

  def test_parse_element_doesnt_parse_symbol
    assert_equal(
      {:char_key => Jesture::KEYMAP[:m]}, 
      Jesture::Config.parse_element(:m))
  end
  
  def test_parse_element_lowercases_input_string
    assert_equal(
      [{:char_key => Jesture::KEYMAP[:m]}], 
      Jesture::Config.parse_element("M"))
  end
  
  def test_parse_element_handles_modifier_keys
    assert_equal(
      {:mod_keys => [Jesture::MODIFIERS[:ctrl]], 
        :char_key => Jesture::KEYMAP[:a]},
      Jesture::Config.parse_element(:ctrl_a))
  end
end

class TestJestureConfigJestureConfig < Test::Unit::TestCase
  def test_presses
    jc = Jesture::Config::JestureDefinition.new do
      presses :foo, "bar"
    end
    assert_equal([:foo, "bar()"], jc.triggers.select { |p| p.first == :foo }.first)
  end
end