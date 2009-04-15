module Backpack
  class SystemObject
    include Parser
    verb "help", :help
    def help
     puts "You need it"
    end
  end
end