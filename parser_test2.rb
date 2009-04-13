# Attempt to make object based system, not verb based.



module Parser
  def self.included(base)
    base.extend ParserReal
  end
  def verblist
    self.class.verblist
  end
  def try_parse(tokens)
    self.class.try_parse(self,tokens)
  end
  class ParserTypes
    def initialize(&block)
      @cond_block = block
    end
  end

  class Noun<ParserTypes
    attr :primary
    def initialize(primary,&block)
      @primary=primary
      super(&block)
    end
  end
  module ParserReal
    attr_reader :verblist

    def metaclass
      class << self; self; end
    end
    def verb(verb,*args)
      puts self.inspect
      @verblist = {} if not defined? @verblist
      method = args.pop
      puts args.inspect
      @verblist[verb]=[args,method]
    end

    def primarynoun(&block)
      Noun.new(true,&block)
    end
    def noun(&block)
      Noun.new(false,&block)
    end

    def try_parse(obj,tokens)
      return if @verblist==nil
      puts tokens.inspect
      if @verblist.include? tokens[0]
        (definition,method) = @verblist[tokens[0]]
        token = 1
        found = true
        # We now have the verb.
        definition.each {|x|
          if x.class==Noun and tokens[token].class==MatchedNoun
            # We're a noun.
            # Check the primary is in the right place.
            if x.primary
              if tokens[token].obj == obj
              else
                puts "Wrong object"
                puts x.primary
                puts tokens[token].obj
                found = false
              end	
            end
          else
            found = false
          end
          token+=1
        }
        if found
          puts "Found"
          return method
        end
      end
    end
  end
end

class BackpackObject
  include Parser
  def metaclass
    class << self; self; end
  end
  def define_method(name, &block)
    metaclass.send(:define_method, name, &block)
  end
end

class A < BackpackObject
  verb "examine", primarynoun, :examine
  verb "check", primarynoun, noun, :something
  def examine
    puts self.inspect
  end
  def inspect
    return "An A"
  end
end

class Jay < BackpackObject
  verb "check", primarynoun, noun, :something
  def something
    puts "Something"
  end
end

b = A.new

@objects = {"b"=>b,"jay"=>Jay.new}
class MatchedNoun
  attr_reader :obj, :str
  def initialize(str,obj)
    @str = str
    @obj = obj
  end
end

def parse(str)
  tokens = str.split()

  # Find the objects in the string
  foundobjects = []
  newtokens = []
  tokens.each do |x|
    if @objects.include? x
      foundobjects << @objects[x]
      newtokens << MatchedNoun.new(x,@objects[x])
    else
      newtokens << x
    end
  end
  puts foundobjects
  foundobjects.each do |x|
    j = x.try_parse(newtokens)
    if j!= nil
      puts "Execute %s" % j.to_s
      x.send(j)
    end
  end
end

parse("examine b")

puts
puts

parse("check jay b")
