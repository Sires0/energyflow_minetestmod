local recipes = {
	{input = "default:coal_lump", output = "default:stonebrick", time = 10,} -- {input then the output then the time to make}
}

local inactive_formspec = "size[8,7]"         ..
"list[current_player;main;0,3;8,4;]"          ..
"list[context;input;1.5,1;1,1;]"              ..
"image[3,1;2,1;arrow_bg.png^[transformR270];]"..
"list[context;output;5.5,1;1,1;]"
local function get_active_formspec(percent)
	local formspec = "size[8,7]"                                                         ..
		"list[current_player;main;0,3;8,4;]"     	                                     ..
		"list[context;input;1.5,1;1,1;]"                                                 ..
		"image[3,1;2,1;arrow_bg.png^[lowpart:".. percent ..":arrow_fg.png^[transformR270]"..
		"list[context;output;5.5,1;1,1;]"
	return formspec
end
local function get_recipe_for(item)
	local recipe = nil
	for i, rec in ipairs(recipes) do
		if rec.input == item then
			recipe = rec
			break
		end
	end
	return recipe
end
local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	if to_list == "output" then
		return 0
	elseif to_list == "input" and inv:is_empty("input") then
		return 1
	else
		return 0
	end
end
local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "output" then
		return 0
	elseif listname == "input" and inv:is_empty("input") then
		return 1
	else
		return 0
	end
end
local function do_that(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local timerref = minetest.get_node_timer(pos)
	local done = meta:get_float("done")
	local time = meta:get_int("time")
	if done == 0.0 then
		local stack = inv:get_stack("input", 1) -- 1 Is the index
		if stack.get_count ~= 0 then
			stack:set_count(stack:get_count() - 1)
			inv:set_stack("input", 1, stack)
		end
	end
	timerref:start(time / 10)
end
minetest.register_node("energyflow:assembler", {
	description = "Assembler",
	tiles = {
		"assembler_top.png",
		"assembler_top.png",
		"assembler_side.png",
		"assembler_side.png",
		"assembler_side.png",
		"assembler_side.png",
	},
	groups = {oddly_breakable_by_hand = 3}, -- That will be changed
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", inactive_formspec)
		meta:set_float("done", 0.0)
		meta:set_string("output", "")
		meta:set_string("input", "")
		meta:set_int("time", 0)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 1)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local done = meta:get_float("done")
		local recipe = get_recipe_for(stack:get_name())
		if recipe ~= nil then
			meta:set_string("output", recipe.output)
			meta:set_string("input", recipe.input)
			meta:set_int("time", recipe.time)
			do_that(pos)
		end
	end,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	on_timer = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local done = meta:get_int("done")
		local output = meta:get_string("output")
		local time = meta:get_int("time")
		local timerref = minetest.get_node_timer(pos)
		print(done)
		if done == 10 then
			meta:set_string("formspec", inactive_formspec)
			inv:set_stack("output", 1, output) -- AAAA why that works just when I try by the second time
			meta:set_float("done", 0.0)
			timerref:stop()
		else
			meta:set_int("done", done + time / 10)
			meta:set_string("formspec", get_active_formspec((done / time) * 100))
			timerref:start(time / 10)
		end
	end
})