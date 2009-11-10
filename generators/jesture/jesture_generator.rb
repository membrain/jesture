class JestureGenerator < Rails::Generator::Base
  
  # This method describes what happens when the generator is invoked.  Here,
  # the default config file is simply copied to the config directory (rails will
  # confirm an overwrite, if appropriate).
  def manifest
    record do |m|
      m.file "jestures.rb", "config/jestures.rb"
    end
  end
  
end