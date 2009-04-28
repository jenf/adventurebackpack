module Backpack
  class Player < BackpackParsableObject
    verb "inventory", :examine
    def initialize(inventory)
      @inventory = inventory
    end
    def examine
      @inventory.examine
    end
  end
  class PlayerInventory < BackpackInventory
  end
end
