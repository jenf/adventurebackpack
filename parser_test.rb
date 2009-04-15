require 'lib/Parser'
require 'readline'

class BackpackObject
  include Parser
end

class BackpackItem < BackpackObject
  verb "examine", primarynoun, :examine
  def examine
    puts self.inspect
  end
end

class Bee < BackpackItem
  def inspect
    "A Bee"
  end
end

class Player < BackpackObject
 verb "inventory", :inventory
 def inventory
   puts "There may be items in here"
 end
end

@objects = {"bee"=>Bee.new}
@nounlessobjects = [Player.new]
@parser = Parser::Parser.new

def parse_and_exec(str)
  puts str
  j = @parser.parse(@objects,@nounlessobjects, str)
  if j!=nil
    (method,primary,others)=j
    puts "Execute %s" % j.to_s
    ret = primary.send(method,others) if others.size!=0
    ret = primary.send(method)        if others.size==0
  end
end

loop do
  line = Readline::readline("> ")
  Readline::HISTORY.push(line)
  parse_and_exec(line)
end
