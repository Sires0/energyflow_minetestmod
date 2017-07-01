-- Coal energy = how many energy the coal generates
-- Energy tick = how many energy per second is generated from the fuel
coal_energy = 100
energy_tick = 5

-- Function to get the formspec when he is active
local function get_active_formspec(percent, energy) 
	local formspec =
		"size[8,9]"..
		"label[3.5,0;Energy: " .. energy .. "]"..
		"list[context;batt;3.5,1;1,1;]".. -- Battery list(I'll make a battery item) 
		"image[3.75,2.25;0.5,0.5;energy_bg.png^[lowpart:" .. percent .. ":energy_fg.png]]".. -- I did a big codekluge here by the line 123, that I don't know what put in the percent arg :)
		"list[context;fuel;3.5,3;1,1;]".. -- In the fuel list you put the coal there
		"list[current_player;main;0,5;8,4;]"
	return formspec
end
-- Function to get the formspec when it isn't active
local function get_inactive_formspec(energy)
	local formspec =
		"size[8,9]"..
		"label[3.5,0;Energy: " .. energy .. "]"..
		"list[context;batt;3.5,1;1,1;]"..
		"image[3.75,2.25;0.5,0.5;energy_bg.png]"..
		"list[context;fuel;3.5,3;1,1;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end
-- Function to allow only coal in the fuel list, and allow only one item in the batt list
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
-- Function to allow move itens
local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end
-- Function to allow take itens
local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	return stack:get_count()
end
-- Function to start the NodeTimer
local function energyproduct(pos)
	local meta = minetest.get_meta(pos)
	local energystorage = meta:get_int("energystorage")
	local fuel = meta:get_int("fuel")
	local timerref = minetest.get_node_timer(pos)
	local inv = meta:get_inventory()
	local fuel_stack = inv:get_stack("fuel", 1) -- 1 is the index
	if not(energystorage + coal_energy > 1000) then
		if fuel_stack:get_count() ~= 0 then
			fuel_stack:set_count(fuel_stack:get_count() - 1)
			inv:set_stack("fuel", 1, fuel_stack)
		end
		timerref:start(1)
		meta:set_int("fuel", fuel + coal_energy)
	end
end
-- Register the generator
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
		local meta = minetest.get_meta(pos)
		meta:set_int("fuel", 0)
		meta:set_int("energystorage", 0)

		meta:set_string("formspec", get_inactive_formspec(0))

		inv = meta:get_inventory()
		inv:set_size("batt", 1)
		inv:set_size("fuel", 1)
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "fuel" then
			if meta:get_int("fuel") == 0 then
				energyproduct(pos)
			end
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if meta:get_int("fuel") == 0 then
			energyproduct(pos)
		end
	end,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,

	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local fuel = meta:get_int("fuel")
		local energystorage = meta:get_int("energystorage")
		local timerref = minetest.get_node_timer(pos)
		local inv = meta:get_inventory()
		local coal = inv:contains_item("fuel", "default:coal_lump")
		if fuel == 0 then
			timerref:stop()
			meta:set_string("formspec", get_inactive_formspec(energystorage))
			if coal then
				energyproduct(pos)
			end
		else
			meta:set_int("fuel", fuel - energy_tick)
			meta:set_int("energystorage", energystorage + energy_tick)
			meta:set_string("formspec", get_active_formspec((fuel / coal_energy)*100, energystorage))
			timerref:start(1)
		end
	end,
})
