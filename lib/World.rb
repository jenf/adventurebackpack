module Backpack
  class World<DSLLoader
    def initialize(objectmanager, dslloader, console, parser)
      @objectmanager = objectmanager.new(dslloader)
      @console = console.new()
      @parser = parser.new()
    end
    def go
      @objectmanager.load(ARGV[0])
      @objectmanager.finalise
      @objectmanager.parse_mode(false)
      @console.read_loop do |x|
        @nounless = [@objectmanager[:Forest], SystemObject.new]
        @objects = {"bird"=>@objectmanager[:Forest].contains[0]}
        j = @parser.parse(@objects,@nounless,x)
        if j!=nil
          (method,primary,others)=j
          puts "Execute %s" % j.to_s
          ret = primary.send(method,others) if others.size!=0
          ret = primary.send(method)        if others.size==0
        end
      end
    end
  end
end