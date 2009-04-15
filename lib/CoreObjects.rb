module Backpack

  class BackpackObject
    include Parser
    attr_reader :manager
    attr_accessor :name, :short_description, :description, :contains
    def metaclass
      class << self; self; end
    end
    def initialize(name, short_description, manager, options)
      @name, @manager, @options = name, manager, options
      @short_description = short_description
      @contains = []
    end
    def define_method(name, &block)
      metaclass.send(:define_method, name, &block)
    end
    def add_exit(sym,roomto)
      define_method(sym) {@manager[roomto]}
    end
    
    def <<(x)
      @contains << x
    end

    def examine
      puts self.inspect
    end
    def inspect
      @short_description + @contains.inspect
    end
  end
  
  class Item < BackpackObject
    verb "examine", primarynoun, :examine
    def initialize(name, short_description, manager,options)
      super
    end
  end

  class BackpackRoom < BackpackObject
    verb "look", :examine
    
    def initialize(name, short_description, manager,options)
      super
    end
    def exits
      exits = []
      methods.each do |x|
        a = x.match(/^exit_([a-zA-Z_]*$)/)
        if a != nil
          exits << a[1]
        end
      end
      return exits
    end
  end
end