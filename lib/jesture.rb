require "keymap"

module Jesture
  class Config
    attr_reader :jestures, :combos
    
    def initialize(file = File.join(RAILS_ROOT, "config", "jestures.rb"))
      @jestures = {}
      @combos = {}
      self.instance_eval(File.read(file))
    end
    
    def combo(name, *sequence)
      @combos[name] = sequence.map { |i| Config.parse_element i }.flatten
    end
    
    def jesture(name, &block)
      raise "I need a block" if !block_given?
      @jestures[name] = JestureDefinition.new(&block)
    end
    
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
    
    class JestureDefinition
      attr_reader :triggers
      
      def initialize(&block)
        @triggers = []
        self.instance_eval(&block)
      end
      
      def presses(combo_name, str = nil, &block)
        @triggers << [ combo_name, block_given? ? block.call : "#{str}()" ]
      end
    end
    
  end
  
  module ControllerMethods
    # Callback to be invoked upon inclusion into ApplicationController
    def self.included(base)
      base.send :alias_method,  :initialize_without_jestures, :initialize
      base.send :alias_method,  :initialize,                  :initialize_with_jestures
      base.send :helper_method, :provide_jesture, :provide_jesture_tag
    end
  
    private
  
    # This method replaces ApplicationController's initialize method (inheritted from
    # ActionController::Base), so that we can get our instance variables set without
    # having to explicitly set them in ApplicationController. 
    def initialize_with_jestures(*args)
      initialize_without_jestures(*args)
      @combos   = {}
      @actions  = []
    end
    
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
    
    def provide_jesture_tag(*args)
      <<-TAG
        <script type="text/javascript">
          #{provide_jesture(*args)}
        </script>
      TAG
    end

    def generate_js(call, sequence)
      <<-JS
        Event.observe(document, "keydown", (function() {
          var l = function(evt) {
            var modifierKeys = [16, 17, 18, 91]; 
            var f   = arguments.callee,
                seq = f.seq;
            
            var charKey = seq[f.i].char_key,
                modKeys = seq[f.i].mod_keys;
                
            if(charKey === evt.keyCode) {
              if(!modKeys || modKeys.all(function(m) {return evt[m]})) {
                f.i++;
              } else {
                f.i = 0;
              }
            } else if (modKeys && modifierKeys.indexOf(evt.keyCode) == -1) {
              /* here we've got a case where we don't want modKeys to
                  reset the sequence because we're detecting them above
                  here. */
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