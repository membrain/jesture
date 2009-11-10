# These commands require the necessary generator librabies.
require 'rails_generator'
require 'rails_generator/scripts/generate'

# This command runs the generator task named jesture.  The task causes the application
# to copy a default configuration file to {RAILS_ROOT}/config.  The default configuration
# file has all options commented out, so it cannot negatively affect your application.
Rails::Generator::Scripts::Generate.new.run(['jesture'], :destination => RAILS_ROOT)