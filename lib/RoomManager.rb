module Backpack
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
end