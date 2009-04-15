module Backpack
  class World<DSLLoader
    def initialize(roommanager, dslloader)
      @roommanager = roommanager.new()
      @dslloader = dslloader.new(@roommanager)
    end
    def go
      @dslloader.load(ARGV[0])
      @dslloader.finalise
      @dslloader.run
    end
  end
end