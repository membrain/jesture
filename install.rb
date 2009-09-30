require 'rails_generator'
require 'rails_generator/scripts/generate'
Rails::Generator::Scripts::Generate.new.run(['jesture'], :destination => RAILS_ROOT)