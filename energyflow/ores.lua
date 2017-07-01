-- Register ores
minetest.register_node("energyflow:stone_with_pzt", {
	tiles = {"default_stone.png^mineral_pzt.png"},
	description = "Pzt Ore",
})
-- Ore generation
minetest.register_ore({
	ore_type = "scatter",
	ore = "energyflow:stone_with_pzt",
	wherein = "default:stone",
	clust_scarcity = 15*15*15,
	clust_num_ores = 3,
	clust_size = 10,
	height_min = -500,
	height_max = -200,
	noise_params = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=3, persist=0.70,},
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "energyflow:stone_with_pzt",
	wherein = "default:stone",
	clust_scarcity = 15*15*15,
	clust_num_ores = 4,
	clust_size = 2,
	height_min = -500,
	height_max = -450,
	noise_params = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=3, persist=0.70,},
})