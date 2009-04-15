module Backpack

  class BackpackObject
    attr_reader :manager
    attr_accessor :short_description, :description, :contains
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
  end
  class Item < BackpackObject
    attr_accessor :name
    def initialize(name, short_description, manager,options)
      super
    end
  end

  class Room < BackpackObject

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