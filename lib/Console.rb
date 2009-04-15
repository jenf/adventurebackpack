module Backpack
  class DSLLoader
    def run
      currentroom=@roommanager[@roommanager.startroom]
      while true
        h=currentroom
        puts h.description 
        puts "Exits : %s" % (h.exits.inspect)
        puts "You can see : %s" % h.contains.collect {|x| x.short_description} if h.contains.size != 0
        j = $stdin.readline.strip
        if h.exits.include? j
          currentroom = h.send("exit_"+j)
        else
          puts "Invalid exit"
        end
      end
    end
  end
end
