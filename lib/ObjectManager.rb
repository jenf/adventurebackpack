module Backpack
  class ObjectManager
    attr_reader :rooms, :startroom
    def initialize(dslmanager, world)
      @rooms = {}
      @startroom = nil
      @current = []
      @parse_mode = true
      @dslmanager = dslmanager.new(self)
      @world = world
    end

    def parse_mode(x)
      @parse_mode = x
    end
    def [](x)
      return @rooms[x]
    end

    def current_room
     @current[-1]
    end
    
    def add_exits_to_room(exits,options={})
      raise 'Not in a room' if current_room == nil
      exits.each {|x,y|
        current_room << BackpackExit.new(x,y, self)
      }
      puts "exits #{exits.inspect}"
    end
    
    def define_room(name, shortdesc, options={}, &block)
      a = BackpackRoom.new(name, shortdesc, self, options)
      current_room << a if current_room!=nil
      @current.push(@rooms[name] = a)
      instance_eval(&block)
      @current.pop()
    end

    def define_item(name, shortdesc, options={}, &block)
      a = BackpackItem.new(name, shortdesc, self, options)
      current_room << a if current_room!=nil
      @current.push(@rooms[name] = a)
      instance_eval(&block)
      @current.pop()
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
      if @parse_mode
        if @dslmanager.respond_to?(sym)
          @dslmanager.send(sym, *args, &block)
        elsif (current_room != nil) and (current_room.respond_to?(v+"="))
          current_room.send(v+'=', *args, &block)
        else
          super
        end
      else
        if @world.respond_to?(sym)
         @world.send(sym, *args, &block)
        else
         super
        end
      end
    end
  end
end