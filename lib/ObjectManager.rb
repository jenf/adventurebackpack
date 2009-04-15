module Backpack
  class ObjectManager
    attr_reader :rooms, :startroom
    def initialize(dslmanager)
      @rooms = {}
      @startroom = nil
      @current = []
      @parse_mode = true
      @dslmanager = dslmanager.new(self)
    end

    def parse_mode(x)
      @parse_mode = x
    end
    def [](x)
      return @rooms[x]
    end

    def define_room(name, shortdesc, options={}, &block)
      a = BackpackRoom.new(name, shortdesc, self, options)
      @current[-1] << a if @current[-1]!=nil
      @current.push(@rooms[name] = a)
      instance_eval(&block)
      @current.pop()
    end

    def define_item(name, shortdesc, options={}, &block)
      a = Item.new(name, shortdesc, self, options)
      @current[-1] << a if @current[-1]!=nil
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
      if @parse_mode and @dslmanager.respond_to?(sym)
        @dslmanager.send(sym, *args, &block)
      end
    end
    
    def method_missing_old(sym, *args, &block)
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