# Attempt to make object based system, not verb based.
module Parser
  def self.included(base)
    base.extend ParserReal
  end

  def run_parse(obj,verbs,tokens)
    exceptions = []
    verbs.each do |verb|
      if verb.verb == tokens[0]
        begin
          # Currently assumes that the first match is good.
          return verb.try_parse(obj, tokens)
        rescue InternalParserError
          puts $!.inspect
        rescue Exception
          puts $!.inspect
          exceptions << [verb, $!]
        end
      end
    end
    raise ParserError,exceptions if exceptions.size!=0
    return nil
  end

  def collect_verbs()
    verbs=[]
    j=self.class
    while defined? j.verblist
      verbs.push(*j.verblist) if j.verblist != nil
      j = j.superclass
    end
    return verbs
  end
  def try_parse(tokens)
    verbs = collect_verbs
    self.run_parse(self,verbs,tokens)
  end
  
  # Errors that are internal and not to be shown to the user (wrong ordering)
  class ParserError<Exception
  end
  class InternalParserError<ParserError
  end

  # Errors that are external and should be shown to the user
  class ExternalParserError<ParserError
  end

  class Verb
    attr_reader :verb,:method,:rest
    def initialize(verb,method,args)
      @verb=verb
      @method=method
      @rest=args
      # To do, validate the rest to ensure there is a primary.
    end

    def try_parse(primarynoun, tokens)
      foundprimary = nil
      othernouns = []
      token = 1
      # Ensure the verb matches the string
      rest.each do |x|
        raise ExternalParserError, "Ran out of input" if token+1>tokens.size
        case x
        when Noun
          # The phrase asks for a noun and we've got a noun
          raise ExternalParserError, "Expected a noun" if tokens[token].class!=MatchedNoun
          # Check the primary is in the right place.
          raise ExternalParserError, "Wrong object" if x.primary and tokens[token].obj != primarynoun
          if not x.primary
            othernouns << tokens[token].obj
          end
        when String
          raise ExternalParserError, "Expected non-noun" if tokens[token].class==MatchedNoun
          raise ExternalParserError, "Expected %s" % x if x != tokens[token]
        when Array
          raise ExternalParserError, "Expected non-noun" if tokens[token].class==MatchedNoun
          raise ExternalParserError, "Expected one of %s" % x.inspect  if not x.include? tokens[token]
        else
          raise ExternalParserError, "Bad type %s" % x
        end
        token+=1
      end
      raise ExternalParserError, "Input remaining (%i %i)" % [token, rest.size] if token!=tokens.size
      return [method,primarynoun,othernouns]
    end
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

    def verb(verb,*args)
      #      puts self.inspect
      @verblist = [] if not defined? @verblist
      method = args.pop
      #      puts args.inspect
      @verblist << Verb.new(verb,method,args)
    end

    def primarynoun(&block)
      Noun.new(true,&block)
    end
    def noun(&block)
      Noun.new(false,&block)
    end
  end

  class MatchedNoun
    attr_reader :obj, :str
    def initialize(obj)
      @obj = obj
    end
  end

  class Parser
    def parse(objects_, nounlessobjects,str)
      tokens = str.split()

      # Find the objects in the string
      foundobjects = []
      newtokens = []
      
      objects = objects_.dup
      curpos = 0
      while curpos < (tokens.size)
        # Be greedy and try and find the longest noun.
        list = objects.map do |x|
         j = x.match_noun(tokens[curpos..-1])
         nil if j == nil
         [x,j] if j != nil
        end
        puts list.inspect
        list.compact!
        if list.size == 0
         newtokens << tokens[curpos]
         curpos+=1
        else
         puts "Found %s" % list.inspect
         # We have items
         if list.size == 1
          foundobjects << list[0][0]
          newtokens << MatchedNoun.new(list[0][0])
          objects.delete list[0][0]
          curpos += list[0][1]+1
         else
          raise "No disambig code yet"
         end
         puts list.inspect
        end
      end
      puts 'ha'
      puts newtokens.inspect
      
      exceptions = []
      # No Nouns found, try implicit search.
      if foundobjects.size == 0
       foundobjects = nounlessobjects
      end
      foundobjects.each do |x|
        begin
          j = x.try_parse(newtokens)
          puts j.inspect
          return j if j!= nil
        rescue ParserError
          puts $!.inspect
        end
      end
      return nil
    end

  end

end
