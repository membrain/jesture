# Load file with symbol-to-keycode mappings.
require "keymap"

# This is the main module.
module Jesture
  
  #------------------------------------------------------------------------------
  # Config defines the logic necessary to load the configuration file, read the
  # DSL, and translate the instructions to javascript.
  #------------------------------------------------------------------------------
  class Config
  
    # Define attributes
    attr_reader :jestures, :combos
    
    # This method initializes the class by setting up instance variables and
    # reading in the configuration file.
    def initialize(file = File.join(RAILS_ROOT, "config", "jestures.rb"))
      @jestures = {}
      @combos   = {}
      self.instance_eval(File.read(file))
    end
    
    # For each combo defined in the config file, we map to name to a sequence
    # of key chords.
    def combo(name, *sequence)
      @combos[name] = sequence.map { |i| Config.parse_element i }.flatten
    end
    
    # For each jesture defined in the config file, we map the name to the
    # block.
    def jesture(name, &block)
      raise "I need a block" if !block_given?
      @jestures[name] = JestureDefinition.new(&block)
    end
    
    # This method converts combo sequence items into key chord objects that can
    # be evaluated by a javascript function.
    def self.parse_element(e)
      if e.respond_to? :split
        e.downcase.split(//).map { |c| { :char_key => KEYMAP[c.to_sym] } }
      else
        a = e.to_s.split(/_+/)
        if a.size > 1
          char_key = a.pop
          mod_keys = a
          
          { :mod_keys => mod_keys.map { |m| MODIFIERS[m.to_sym] },
            :char_key => KEYMAP[char_key.to_sym] }
            
        else
          { :char_key => KEYMAP[e] || e.to_i }
        end
      end
    end
    
    
    #------------------------------------------------------------------------------
    # JestureDefinition defines the logic necessary to load jesture blocks from
    # the configuration file.
    #------------------------------------------------------------------------------
    class JestureDefinition
      
      # Define attributes
      attr_reader :triggers
      
      # This method initializes the class by setting up instance variables and
      # continuing the evaluation of the configuration file.
      def initialize(&block)
        @triggers = []
        self.instance_eval(&block)
      end
      
      # For each presses defined for the jesture, we map the name to the
      # combo to runnable javascript (for functions, we automatically convert 
      # to an invocation).
      def presses(combo_name, str = nil, &block)
        @triggers << [ combo_name, block_given? ? block.call : "#{str}()" ]
      end
    end
    
  end
  
  
  
  #------------------------------------------------------------------------------
  # These methods are mixed into application controllers.
  #------------------------------------------------------------------------------
  module ControllerMethods
    
    # This method is a callback that is invoked upon inclusion into ApplicationController.
    def self.included(base)
      
      # Save reference to original initialize method; remap initialize to our method
      base.send :alias_method,  :initialize_without_jestures, :initialize
      base.send :alias_method,  :initialize,                  :initialize_with_jestures
      
      # Provide helper methods to views
      base.send :helper_method, :provide_jesture, :provide_jesture_tag
    end
  
  
    private
  
    # This method replaces ApplicationController's initialize method (inherited from
    # ActionController::Base), so that we can get our instance variables set without
    # having to explicitly set them in ApplicationController. 
    def initialize_with_jestures(*args)
      initialize_without_jestures(*args)
      @combos   = {}
      @actions  = []
    end
    
    # This method reads the config file and uses the supplied jesture name(s) to include the
    # require javascript. This method returns inline javascript. 
    def provide_jesture(*args)
      config = Jesture::Config.new
      
      ([ args ].flatten.map do |name|
        raise "There is no jesture by that name! (:#{name.to_s})" if !config.jestures.has_key?(name)
      
        result = []
        jesture = config.jestures[name]
        jesture.triggers.each do |t|
          sequence  = config.combos[t.first]
          js_call   = t.last
        
          result << generate_js(js_call, sequence)
        end
        result.join 
      end).join   # parens don't have to be here, but it looks a little cleaner
    end
    
    # This method wraps the output from provide_jesture in a javascript script tag. 
    def provide_jesture_tag(*args)
      <<-TAG
        <script type="text/javascript">
          #{provide_jesture(*args)}
        </script>
      TAG
    end

    # This method produces the javascript necessary to map the combo to the 
    # trigger code.
    def generate_js(call, sequence)
      <<-JS
        Event.observe(document, "keydown", (function() {
          var l = function(evt) {
            var modifierKeys = [16, 17, 18, 91]; 
            var f   = arguments.callee,
                seq = f.seq;
            
            var charKey = seq[f.i].char_key,
                modKeys = seq[f.i].mod_keys;
                
            /* if match and no mod keys required or match and all mod keys
               included, advance sequence position; else reset */   
            if (charKey === evt.keyCode) {
              if (!modKeys || modKeys.all(function(m) {return evt[m]})) {
                f.i++;
              } else {
                f.i = 0;
              }
            } 
            /* else, if no match and the mismatch wasn't caused by a required 
               modifiers keydown event, reset */
            else if (!modKeys || modifierKeys.indexOf(evt.keyCode) == -1) {
              f.i = 0;
            }

            if(f.i === seq.length) {
              f.i = 0;
              #{call}
            }
          }
        
          l.seq = #{ActiveSupport::JSON.encode(sequence)};
          l.i   = 0;
        
          return l;
        })());
      JS
    end
  end
end