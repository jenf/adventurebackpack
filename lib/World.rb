module Backpack
  class World<DSLLoader
    def initialize(dslloader)
      @dslloader = dslloader.new()
    end
    def go
      @dslloader.load(ARGV[0])
      @dslloader.finalise
      @dslloader.run
    end
  end
end