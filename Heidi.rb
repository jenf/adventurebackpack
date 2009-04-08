room :BeforeForest do
 description "You stand outside a cottage. The forest stretches east."
 short_description "In front of a cottage"
 exit_east :Forest
end

room :Forest do
 description "Through the dense foliage, you glimpse a building to the west."
             "A track heads to the northeast."
 short_description "Deep in the forest"
 exit_north_east :Clearing
end

room :Clearing do
 short_description "A forest clearing"
 description "A tall sycamore stands in the middle of this clearing."
             "The path winds southwest through the trees."
 exit_up :TopOfTree
end

room :TopOfTree do
 short_description "At the top of the tree"
 description "You cling precariously to the trunk"
end

start_room :BeforeForest