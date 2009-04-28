require 'lib/Parser.rb'
require 'test/unit'
require 'logger'

class BackpackObject
 include Parser
end

class BackpackItem < BackpackObject
  verb "examine", primarynoun, :examine
  def examine
   puts self.inspect
  end 
  def match_noun(x)
   puts self.class.to_s
   return 0 if x[0]==self.class.to_s.downcase
   return nil
  end
end

class Bee < BackpackItem
  verb "check", primarynoun, noun, :something
  verb "put", noun, ["into","in","inside","through"], primarynoun,:insert
  verb "specialput", noun, "in", primarynoun,:insert
  def insert(x)
    puts "insert %s" % x
  end

  def inspect
    return "An Bee"
  end
 
end

class Jay < BackpackItem
end

class Player < BackpackObject
  verb "inventory", :inventory
  def inventory
   puts "There may be items in here"
  end
end

class ParserTest < Test::Unit::TestCase
 def setup
  @bee = Bee.new
  @jay = Jay.new
  @objects = [@bee,@jay]
  @nounlessobjects = [Player.new]
  @parser = Parser
 end

 def parse(str)
  @parser.parse(@objects, @nounlessobjects, str)
 end
 
 def test_examine
  assert_nil parse("examine")
  assert_equal [:examine, @bee, []], parse("examine bee")
  assert_equal [:examine, @jay, []], parse("examine jay")
  assert_nil parse("examine bee bee")
  assert_nil parse("examine fred")
 end
 
 def test_put
  assert_nil parse("put")
  assert_nil parse("put bee")
  assert_nil parse("put jay likeinto bee")
  assert_equal [:insert, @bee,[@jay]], parse("put jay into bee")
  assert_nil parse("put jay into bee bee")
 end
 
 def test_specialput
  assert_nil parse("specialput")
  assert_nil parse("specialput bee")
  assert_nil parse("specialput jay likeinto bee")
  assert_equal [:insert, @bee,[@jay]], parse("specialput jay in bee")
  assert_nil parse("specialput jay in bee bee")
 end
 
 def test_inventory
  assert_nil parse("inventory self")
  assert_equal [:inventory, @nounlessobjects[0],[]], parse("inventory")
 end
 def parse_and_exec(str)
  #puts str
  j = @parser.parse(@objects,@nounlessobjects, str)
  if j!=nil
    (method,primary,others)=j
    puts "Execute %s" % j.to_s
    ret = primary.send(method,others) if others.size!=0
    ret = primary.send(method)        if others.size==0
  end
end
end

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
Parser.logger = logger
@objects = [Bee.new,Jay.new]
@nounlessobjects = [Player.new]
@parser = Parser
puts @parser.parse(@objects, @nounlessobjects, "inventory")