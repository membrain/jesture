# Add this plugin's lib directory to the rails load path.
$LOAD_PATH.unshift(File.join(__FILE__, "lib"))

# Include jesture and mix its controller methods in the base ActionController
# class.
require "jesture"
ActionController::Base.class_eval { include Jesture::ControllerMethods }