require 'readline'
module Backpack
  class Console
    def output(x)
      puts (x)
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
