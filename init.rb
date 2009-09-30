$LOAD_PATH.unshift(File.join(__FILE__, "lib"))
require "jesture"
ActionController::Base.class_eval { include Jesture::ControllerMethods }