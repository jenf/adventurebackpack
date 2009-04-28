module Backpack
  class DSLLoader
    attr_reader :load_paths

    def initialize(objectmanager) 
      @load_paths = ['.']
      @objectmanager = objectmanager
    end

    def load(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each { |arg| load options.merge(:file => arg) }
      return unless args.empty?

      if block
        raise 'Loading a block requires 2 parameters' unless args.empty?
        load(options.merge(:proc => block))

      elsif options[:file]
        file = options[:file]
        load :string => File.read(file), :name => options[:name] || file

      elsif options[:string]
        instance_eval(options[:string], options[:name] || "<eval>")

      elsif options[:proc]
        instance_eval(&options[:proc])

      else
        raise ArgumentError, "Don't know how to load #{options.inspect}"
      end
    end

    def room(name, shortdesc, options={}, &block)
      klass = (options[:class] || BackpackRoom)
      @objectmanager.define_item(klass,name,shortdesc, options,&block)
    end

    def item(name, shortdesc, options={}, &block)
      klass = (options[:class] || BackpackItem)
      @objectmanager.define_item(klass,name,shortdesc, options,&block)
    end

    def add_exits(options = {})
     exits = {}
     options.each do |x,y|
      case x
       when :autoinvert
       when :autoname
       else
        j = y
        j = [j] if j.class == String # Convert string to array automatically
        exits[x] = y
        options.delete(x)
      end
     end
     @objectmanager.add_exits_to_room(exits,options)
    end
    
    def start_room(name, options={})
      @objectmanager.start_room(name,options)
    end
    def finalise
      @objectmanager.autoinvert_paths
    end
    
    def player(options = {},&block)
       klass = (options[:class] || Backpack::Player)
       inventoryklass = (options[:inventory_class] || Backpack::PlayerInventory)
       @objectmanager.define_player(klass,inventoryklass,&block)
    end
  end
end