combo :foo, :left, :right, :left, :right
combo :bar, :up, :up, :up
combo :uppity, 38, 38, 38, 38
combo :konami, :up, :up, :down, :down, :left, :right, :left, :right, :b, :a, :enter
combo :epileptichrome, "moodlight"
combo :shutup, :ctrl_shift_s

jesture :fight do
  presses :foo do
    "document.body.innerHTML += 'Fight!'"
  end
end

jesture :color_change do
  presses :bar, "Foo.bar"
end

jesture :complainer do
  presses :uppity, "alert('Eww! None of those here!')"
end

jesture :fantasy do
  presses :konami, "Foo.unicorns"
end

jesture :mood_light do
  presses :epileptichrome, "Foo.lsd"
end