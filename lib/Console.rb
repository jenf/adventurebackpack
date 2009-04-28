require 'readline'
module Backpack
  class Console
    def puts(x)
      super
    end
    
    def read_loop
      loop do
        line = Readline::readline("> ")
        Readline::HISTORY.push(line)
        yield line
      end
    end
  end
end
