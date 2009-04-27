module Backpack
  class SystemObject<BackpackParsableObject
    def initialize(world)
     @world = world
    end
    
    verb "help", :help
    def help
     puts "You need it"
    end
    
    verb "room", :room
    def room
     puts @world.currentroom.inspect
    end
  end
end