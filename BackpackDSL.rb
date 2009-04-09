require 'singleton'
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
  class RoomManager
    attr_reader :rooms, :startroom
    def initialize
      @rooms = {}
      @startroom = nil
      @current = nil
    end

    def [](x)
      return @rooms[x]
    end

    def define_room(name, shortdesc, options={}, &block)
      @current = @rooms[name] = Room.new(name, shortdesc, self, options)
      instance_eval(&block)
      return @current
    end

    def define_item(name, shortdesc, options={}, &block)
      @current = @rooms[name] = Item.new(name, shortdesc, self, options)
      instance_eval(&block)
      return @current
    end

    def item(name, shortdesc, options={}, &block)
      j = @current
      j.contains << define_item(name, shortdesc, options, &block)
      @current = j
    end

    def start_room(name, options={})
      @startroom=name
    end

    def autoinvert_paths
      inverse = {"east"=>"west" , "north" =>"south",
        "northeast" => "southwest", "northwest" => "southeast",
        "up" => "down"}
      # Fill in the inverse of the list
      inverse.each {|x,y| inverse[y]=x}
      @rooms.each {|x,y|
        y.methods.each {|v|
          if v =~ /exit_([a-zA-Z_]*)$/
            dir = $1
            if inverse.include? dir
              # get room destination
              @current = y.send(v)
              self.send("exit_"+inverse[dir],x)
            end
          end
        }
      }
    end


    def method_missing(sym, *args, &block)
      v=sym.to_s
      if v =~ /exit_([a-zA-Z_]*$)/
        var = args[0]
        @current.add_exit(sym,var)
      else
        if @current.respond_to?(v+"=")
          @current.send(v+'=', *args, &block)
        else
          super
        end
      end
    end
  end
  class Configuration
    attr_reader :load_paths

    def initialize() 
      @load_paths = ['.']
      @roommanager = RoomManager.new
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
      @roommanager.define_room(name,shortdesc, options,&block)
    end

    def item(name, shortdesc, options={}, &block)
      @roommanager.define_item(name,shortdesc, options,&block)
    end

    def start_room(name, options={})
      @roommanager.start_room(name,options)
    end
    def finalise
      @roommanager.autoinvert_paths
    end
  end
end

module Backpack
  class World
    attr_reader :configuration
    def initialize
      @configuration = Backpack::Configuration.new
    end
    def go
      configuration.load(ARGV[0])
      configuration.finalise
      configuration.run
      #    configuration.run
    end
  end
end

module Backpack
  class Configuration
    def run
      currentroom=@roommanager[@roommanager.startroom]
      while true
        h=currentroom
        puts h.description 
        puts "Exits : %s" % (h.exits.inspect)
        puts "You can see : %s" % h.contains.collect {|x| x.short_description} if h.contains.size != 0
        j = $stdin.readline.strip
        if h.exits.include? j
          currentroom = h.send("exit_"+j)
        else
          puts "Invalid exit"
        end
      end
    end
  end
end
