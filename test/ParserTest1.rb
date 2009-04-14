require 'lib/Parser.rb'
require 'test/unit'

class BackpackObject
 include Parser

end

class Bee < BackpackObject
  verb "check", primarynoun, noun, :something
  verb "put", noun, ["into","in","inside","through"], primarynoun,:insert
  verb "specialput", noun, "in", primarynoun,:insert
  def insert(x)
    puts "insert %s" % x
  end
  verb "examine", primarynoun, :examine
  def examine
   puts self.inspect
  end 
  def inspect
    return "An Bee"
  end
end

class Jay < BackpackObject
  verb "check", primarynoun, noun, :something
  def something(x)
    puts "Something %s" % x.inspect
  end
end

class ParserTest < Test::Unit::TestCase
 def setup
  @objects = {"bee"=>Bee.new,"jay"=>Jay.new}
  @parser = Parser::Parser.new
 end

 def parse(str)
  @parser.parse(@objects,str)
 end
 
 def test_examine
  assert_nil parse("examine")
  assert_equal parse("examine bee"), [:examine, @objects["bee"], []]
  assert_nil parse("examine bee bee")
  assert_nil parse("examine fred")
 end
 
 def test_put
  assert_nil parse("put")
  assert_nil parse("put bee")
  assert_nil parse("put jay likeinto bee")
  assert_equal parse("put jay into bee"), [:insert, @objects["bee"],[@objects["jay"]]]
  assert_nil parse("put jay into bee bee")
 end
 
 def test_specialput
  assert_nil parse("specialput")
  assert_nil parse("specialput bee")
  assert_nil parse("specialput jay likeinto bee")
  assert_equal parse("specialput jay in bee"), [:insert, @objects["bee"],[@objects["jay"]]]
  assert_nil parse("specialput jay in bee bee")
 end
 
 def parse_and_exec(str)
  puts str
  j = @parser.parse(@objects,str)
  if j!=nil
    (method,primary,others)=j
    puts "Execute %s" % j.to_s
    ret = primary.send(method,others) if others.size!=0
    ret = primary.send(method)        if others.size==0
  end
end
end

@objects = {"bee"=>Bee.new,"jay"=>Jay.new}
@parser = Parser::Parser.new
@parser.parse(@objects,"examine bee")