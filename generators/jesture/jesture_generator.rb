class JestureGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      m.file "jestures.rb", "config/jestures.rb"
    end
  end
  
end