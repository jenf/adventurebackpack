module Backpack
  class DSLLoader
    attr_reader :load_paths

    def initialize(roommanager) 
      @load_paths = ['.']
      @roommanager = roommanager
    end

    def load(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each { |arg| load options.merge(:file => arg) }
      return unless args.empty?

      if block
        raise 'Loading a block requires 2 parameters' unless args.empty?
        load(options.merge(:proc => block))

      elsif options[:file]
        file = options[:file]
        load :string => File.read(file), :name => options[:name] || file

      elsif options[:string]
        instance_eval(options[:string], options[:name] || "<eval>")

      elsif options[:proc]
        instance_eval(&options[:proc])

      else
        raise ArgumentError, "Don't know how to load #{options.inspect}"
      end
    end

    def room(name, shortdesc, options={}, &block)
      @roommanager.define_room(name,shortdesc, options,&block)
    end

    def item(name, shortdesc, options={}, &block)
      @roommanager.define_item(name,shortdesc, options,&block)
    end

    def start_room(name, options={})
      @roommanager.start_room(name,options)
    end
    def finalise
      @roommanager.autoinvert_paths
    end
  end
end