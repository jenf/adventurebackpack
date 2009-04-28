require 'logger'

module Backpack
  def self.logger
    return @logger
  end
  def self.logger=(x)
    @logger=x
  end
  
  class World
    attr_reader :currentroom
    def initialize(objectmanager, dslloader, console, parser)
      @objectmanager = objectmanager.new(dslloader, self)
      @console = console.new()
      @parser = parser
      @systemobject = SystemObject.new(self)
      @player = nil
    end
    def start_world
      @objectmanager.load(ARGV[0])
      
      # Define player if not done
      if @player==nil
        @objectmanager.player do
        end
      end
      
      @objectmanager.finalise
      @objectmanager.parse_mode(false)
      @currentroom = @objectmanager[@objectmanager.startroom]
      @console.puts @currentroom.examine
      
      @console.read_loop do |x|
        @nounless = [@currentroom, @systemobject, @player]
        @objects = @currentroom.contains
        Backpack.logger.debug(@objects.inspect)
        j = @parser.parse(@objects.dup,@nounless,x)
        if j!=nil
          (method,primary,others)=j
          Backpack.logger.debug("Execute %s" % j.to_s)
          ret = primary.send(method,others) if others.size!=0
          ret = primary.send(method)        if others.size==0
          @console.puts ret
        else
          @console.puts "I didn't know what to make of that"
        end
      end
    end
    
    def set_room(room)
      @currentroom = @objectmanager[room]
    end
    def player=(player)
      @player = player
    end
  end
end