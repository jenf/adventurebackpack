require 'singleton'
module Backpack
  class Room
    attr_accessor :short_description, :description

    def initialize(name, manager,options)
      @name, @manager, @options = name, manager, options
    end
    def metaclass
      class << self; self; end
    end
    def define_method(name, &block)
      metaclass.send(:define_method, name, &block)
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

    def define_room(name, options={}, &block)
      @current = @rooms[name] = Room.new(name, self, options)
      instance_eval(&block)
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
              destination = y.send(v)
              @current = @rooms[destination]
              self.send("exit_"+inverse[dir],x)
            end
            puts $1
          end
        }
      }
    end
    def method_missing(sym, *args, &block)
      v=sym.to_s
      if v =~ /exit_([a-zA-Z_]*$)/
        var = args[0]
        @current.define_method(sym) {var}
        puts v
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

    def room(name, options={}, &block)
		  puts name
      @roommanager.define_room(name,options,&block)
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
		  puts @roommanager.inspect
      currentroom=@roommanager.startroom
      while true
        h=@roommanager[currentroom]
        puts h.description 
        puts "Exits : %s" % (h.exits.inspect)
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
