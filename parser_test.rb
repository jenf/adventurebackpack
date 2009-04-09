class Verb
 attr_reader :list
 def initialize(&block)
 	@list = []
  instance_eval(&block)
 end
 def noun(&block)
   Noun.new(false,&block)
 end
 def actionnoun(&block)
   Noun.new(true,&block)
 end

 def multiexcept(&block)
   MultiExcept.new(&block)
 end

 def any(*args)
   return args
 end
 
 def declare(sym,*args)
   @list << [sym,args]
 end
 
 def try_match(text, objects)
  word = 0
	@list.each do |x|
	 fail = false
	 objs = []
	 puts x[1].inspect
	 puts "yo"
	 x[1].each {|y|
	  puts y.class
		puts "fred"
	  case y
		 when Noun
		  if not objects.include? text[word]
			 fail = true
			else
			 objs << [y,objects[text[word]]]
			 word +=1
			end
		 when String
		  if y != text[word]
			 fail = true 
			else
			 word +=1
			end
		 when Array
		  if not y.include? text[word] 
			 fail = true
			else
			 word +=1
			end
		else
			fail = true
		end
		break if fail
	 }
	 
	 if not fail
	 # sort out the two objects
	 firstobj=nil
	 secondobj=nil
	 objs.each {|a,b|
	  if a.class == Noun and a.action
		 firstobj = b
		else
		 secondobj = b
		end
	 }
	 return [firstobj,x[0],secondobj]
	 end
	end
 end
end

class ParserTypes
  def initialize(&block)
	 @cond_block = block
  end
end

class Noun<ParserTypes
 attr :action
 def initialize(action,&block)
  @action=action
	super(&block)
 end
end

class MultiExcept<ParserTypes
end



@verbs={}
def verb(*verbs,&block)
 j = Verb.new(&block)
 verbs.each {|x| @verbs[x] = j}
end

verb "go","run","walk" do
 declare :go, actionnoun {|x| x.direction?}
 declare :enter, actionnoun
 declare :enter, ["into","in","inside","through"], actionnoun
end

verb "look" do
 declare :look
end

verb "put" do
 declare :insert, noun, ["in","inside","into"], actionnoun
end

class A
 def insert(v)
  puts "insert "+v.inspect
 end
 def go
  puts "go"
 end
end

class B
end

puts @verbs.inspect
@currentobjects = {"a"=>A.new, "b"=>B.new}
def parse(x)
 j=x.split
 puts j
 if @verbs.include? j[0]
  return @verbs[j[0]].try_match(j[1..-1],@currentobjects)
 else
  raise "No such verb ${j[0]}"
 end
end

def exec(k)
 puts k.inspect
 (first,action,second)=k
 if second != nil
  first.send(action,second)
 else
  first.send(action)
 end
end

k=parse "put b into a"
exec k
k=parse "go a"
exec k
