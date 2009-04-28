module Backpack
  class BackpackInventory<Array
    def examine
      case self.empty?
       when true
         "Empty"
       else
         self.map {|x| x.glance}.join(", ")
      end
    end
  end
  
  class BackpackParsableObject
      include Parser
  end
  class BackpackObject<BackpackParsableObject
    attr_reader :manager
    attr_accessor :name, :short_description, :description, :contains
    def metaclass
      class << self; self; end
    end
    def initialize(name, short_description, manager, options)
      @manager, @options = manager, options
      @name = name.class==String ? [name] : name
      @short_description = short_description
      @contains = BackpackInventory.new
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

    def glance
      short_description
    end
    
    def examine
      description + "\n" + contains.examine
    end
    
    def examine_contents
      contains.inspect
    end
#    def inspect
#      "#{@name} : #{@short_description}" + @contains.inspect
#    end
    
    def match_noun(x)
     Backpack.logger.info("%s *%s* %s" % [@name.inspect,x[0],@name.include?(x[0])])
     return 0 if @name.include?(x[0])
     return nil
    end
    
    def exit?
      false
    end
    
    def item?
      false
    end
  end
  
  class BackpackVisibleObject < BackpackObject
    verb "examine", primarynoun, :examine
  end
  
  class BackpackItem < BackpackVisibleObject
    def item?
      false
    end
  end

  class BackpackExit < BackpackVisibleObject
    verb "go", primarynoun, :go
    def initialize(exit, names, manager)
     @exit = exit
     super(names, exit.to_s, manager, {})
    end
    
    def exit?
      true
    end
    
    def go
     manager.set_room(@exit)
     manager.currentroom.examine
    end
    
    def examine
     manager[@exit].short_description
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
    def inspect
     @name.inspect
    end
  end
end
