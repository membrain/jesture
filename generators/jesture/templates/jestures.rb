#----------------------------------------------------------------------------------------------------
# Combos define key sequences that should trigger actions. Key sequences can be defined in symbols,
# key code numbers, or any combination of the two
#----------------------------------------------------------------------------------------------------

# combo :konami,            :up, :up, :down, :down, :left, :right, :left, :right, :b, :a, :enter
# combo :find,              :ctrl_f
# combo :ups,               38, 38, 38
# combo :downs,             40, 40, 40
# combo :lefts,             37, 37, 37
# combo :rights,            39, 39, 39
# combo :mix_and_match,     :ctrl_y, 38, :down



#----------------------------------------------------------------------------------------------------
# Jestures associate actions to combos.  Generally speaking, each jesture contains one presses
# block, but if it makes sense to define a series of action-to-combo associations as a single 
# set, jesture will accommodate that.
#----------------------------------------------------------------------------------------------------

# A simple inline javascript call.
# jesture :fight do
#   presses :konami do
#     "alert('Fight!');"
#   end
# end

# A call to an existing javascript function
# jesture :invoke_find_dialog do
#   presses :find, "myObj.myMethod"
# end

# Multiple mappings within a single jesture definition
# jesture :arrow_keys do
#   presses :ups do
#     "alert('three ups!');"
#   end
#   presses :downs do 
#     "alert('three downs!');"
#   end
#   presses :lefts do 
#     "alert('three lefts!');"
#   end
#   presses :rights do 
#     "alert('three rights!');"
#   end
# end