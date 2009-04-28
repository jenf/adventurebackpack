module Backpack
  class Player < BackpackParsableObject
    verb "self", :examine
    def examine
      "What a guy"
    end
  end
end
