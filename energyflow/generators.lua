
local function factive_formspec(percent, energy) 
	local formspec =
		"size[8,9]"..
		"label[3.5,0;Energy: " .. energy .. "]"..
		"list[context;batt;3.5,1;1,1;]"..
		"image[3.75,2.25;0.5,0.5;energy_bg.png^[lowpart:" .. (100 - percent) .. ":energy_fg.png]]"..
		"list[context;fuel;3.5,3;1,1;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end
local function inactive_formspec(energy)
	local formspec =
		"size[8,9]"..
		"label[3.5,0;Energy: " .. energy .. "]"..
		"list[context;batt;3.5,1;1,1;]"..
		"image[3.75,2.25;0.5,0.5;energy_bg.png]"..
		"list[context;fuel;3.5,3;1,1;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end
local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	meta = minetest.get_meta(pos)
	inv = meta:get_inventory()
	if listname == "fuel" then
		if stack:get_name() == "default:coal_lump" then
			return stack:get_count()
		else
			return 0
		end
	elseif listname == "batt" and inv:is_empty("batt") then
		return 1
	else
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	return stack:get_count()
end
minetest.register_node("energyflow:fuel_gen", {
	tiles = {
	"mkb.png",
	"mkb.png",
	"mkb.png",
	"mkb.png",
	"mkb.png",
	"fuel_gen.png",
	},
	paramtype2 = "facedir",
	description = "Fuel Generator",
	groups = {oddly_breakable_by_hand = 3},
	on_construct = function(pos)
		meta = minetest.get_meta(pos)
		meta:set_float("timer", 0)
		meta:set_int("fuel", 0)
		meta:set_int("energystorage", 0)
		meta:set_string("formspec", inactive_formspec(0))
		inv = meta:get_inventory()
		inv:set_size("batt", 1)
		inv:set_size("fuel", 1)
	end,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})