# Heidi Example for Adventure Backpack


# world do
# description "A simple Inform example"
#             "by Roger Firth and Sonja Kesserich. (Ported by Jennifer Freeman)"
start_room :BeforeForest
# end

room :BeforeForest,"In front of a cottage",:autoname=>false do
 description "You stand outside a cottage. The forest stretches east."
 add_exits :Forest => "east"
 name ["building","cottage"]
end

room :Forest, "Deep in the forest" do
 description "Through the dense foliage, you glimpse a building to the west.\n" \
             "A track heads to the northeast."
 add_exits :Clearing =>"northeast"
 add_exits :BeforeForest=>"west"
 
 item :Bird, "Baby bird" do
  description "Too young to fly, the nestling tweets helplessly."
  name ["baby","bird","nestling"]
 end
end

room :Clearing, "A forest clearing" do
 description "A tall sycamore stands in the middle of this clearing."
             "The path winds southwest through the trees."
# exit_up :TopOfTree
# 
 item :Nest, "Bird's nest", :container=>:open do
  description "The nest is carefully woven of twigs and moss."
  name ["Nest","twigs", "moss"]
 end
 add_exits :TopOfTree=>"up"
# 
# item :Tree, "Tree", :collectable=>false do
#  description "Standing proud in the middle of the clearing,"
#              "the stout tree looks easy to climb."
#  name ["Tall", 'sycamore','tree','stout','proud']
# end
end

room :TopOfTree, "At the top of the tree" do
 description "You cling precariously to the trunk"
 item :Branch, "Wide firm branch", :supporter=>true do
  description "It's flat enough to support a small object."
  name ["wide",'firm','flat','bough','branch']
  # on_add :Nest {|x| win_game}
 end
end

# player do
 # inventory :size=>1
# end
