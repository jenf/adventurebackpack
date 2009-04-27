module Backpack
  class World
    attr_reader :currentroom
    def initialize(objectmanager, dslloader, console, parser)
      @objectmanager = objectmanager.new(dslloader, self)
      @console = console.new()
      @parser = parser.new()
      @systemobject = SystemObject.new(self)
    end
    def start_world
      @objectmanager.load(ARGV[0])
      @objectmanager.finalise
      @objectmanager.parse_mode(false)
      @currentroom = @objectmanager[@objectmanager.startroom]
      @console.read_loop do |x|
        @nounless = [@currentroom, @systemobject]
        @objects = @currentroom.contains
        j = @parser.parse(@objects.dup,@nounless,x)
        if j!=nil
          (method,primary,others)=j
          puts "Execute %s" % j.to_s
          ret = primary.send(method,others) if others.size!=0
          ret = primary.send(method)        if others.size==0
        end
      end
    end
    
    def set_room(room)
      @currentroom = @objectmanager[room]
    end
  end
end