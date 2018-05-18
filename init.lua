--
-- Mid-Measure [mid_measure]
--
-- Quickly get the distance between two nodes and calculate their mid-point
--

---------------------------------------------------------------------------

-- 'Enum' to keep track of current operation
local none_set, pos1_set, pos2_set, midpoint_set = 0, 1, 2, 3

local distance, midpoint

local instances = {}

minetest.register_on_joinplayer(function(player)
	instances[player:get_player_name()] = {
		pos1 = {x=0, y=0, z=0},
		pos2 = {x=0, y=0, z=0},
		pos_mid = {x=0, y=0, z=0},
		node1 = {name = ""},
		node2 = {name = ""},
		node_mid = {name = ""},
		mark_status = none_set
	}
end)

-- pos1 marker node
minetest.register_node("mid_measure:pos1", {
	description = "Mid-Measure Pos1",
	tiles = {"mid_measure_pos1.png"},
	is_ground_content = false,
	light_source = minetest.LIGHT_MAX,
	groups = {not_in_creative_inventory, immortal}	
})

-- pos2 marker node
minetest.register_node("mid_measure:pos2", {
	description = "Mid-Measure Pos2",
	tiles = {"mid_measure_pos2.png"},
	is_ground_content = false,
	light_source = minetest.LIGHT_MAX,
	groups = {not_in_creative_inventory, immortal}
})

-- Mid-point marker node
minetest.register_node("mid_measure:midpoint", {
	description = "Mid-Measure Mid-point",
	tiles = {"mid_measure_midpoint.png"},
	is_ground_content = false,
	light_source = minetest.LIGHT_MAX,
	groups = {not_in_creative_inventory, immortal}	
})

-- Marks pos1
function mark_pos1(player, pos)
	instances[player].pos1 = pos
	instances[player].node1 = minetest.get_node(pos)
	minetest.swap_node(pos, {name = "mid_measure:pos1"})
	tell_player(player, "pos1 marked!")
	instances[player].mark_status = pos1_set
end

-- Marks pos2 and performs calculations
function mark_pos2(player, pos)
	instances[player].pos2 = pos
	instances[player].node2 = minetest.get_node(pos)
	minetest.swap_node(pos, {name = "mid_measure:pos2"})
	tell_player(player, "pos2 marked!")
	instances[player].mark_status = pos2_set
	
	-- Calculate the distance and display output
	distance = math.floor(vector.distance(instances[player].pos1, instances[player].pos2) + 0.5)
	tell_player(player, "Distance between the two nodes = " .. minetest.colorize("#FFFF00", distance))
				
	if distance == 1 then
		tell_player(player, "pos1 and pos2 are right next to each other. Mid-point has not been marked.")
		return
	end
				
	-- Calculate mid-point and display output
	instances[player].pos_mid = vector.new((instances[player].pos1.x + instances[player].pos2.x)/2,
											(instances[player].pos1.y + instances[player].pos2.y)/2,
											(instances[player].pos1.z + instances[player].pos2.z)/2)
	instances[player].node_mid = minetest.get_node(instances[player].pos_mid)
	minetest.swap_node(instances[player].pos_mid, {name = "mid_measure:midpoint"})
	tell_player(player, "Mid-point at " .. minetest.colorize("#FFFF00", minetest.pos_to_string(instances[player].pos_mid)))
	instances[player].mark_status = midpoint_set

	-- Reads auto-reset duration from conf, defaults to 60 seconds if setting non-existent
	local auto_reset = tonumber(minetest.settings:get("mid_measure.auto_reset"))
	if not auto_reset then
		auto_reset = 30
		minetest.settings:set("mid_measure.auto_reset", auto_reset)
	end
			
	-- Auto-reset is disabled if auto_reset == 0
	if auto_reset ~= 0 then
		 minetest.after(auto_reset, reset, player)
	end
end

-- Resets pos1 and pos2; replaces marker nodes with the old nodes
function reset(player)
	if instances[player].mark_status == none_set then
		return
	end
	
	if instances[player].mark_status == pos1_set then
		minetest.swap_node(instances[player].pos1, instances[player].node1)
	elseif instances[player].mark_status == pos2_set then
		minetest.swap_node(instances[player].pos1, instances[player].node1)
		minetest.swap_node(instances[player].pos2, instances[player].node2)
	elseif instances[player].mark_status == midpoint_set then
		minetest.swap_node(instances[player].pos1, instances[player].node1)
		minetest.swap_node(instances[player].pos2, instances[player].node2)
		minetest.swap_node(instances[player].pos_mid, instances[player].node_mid)
	end
		
	instances[player].mark_status = none_set
	
	
	if minetest.get_player_by_name(player) then
		tell_player(player, "pos1, pos2 and mid-point have been reset.")
	end
end
	
-- Convenience method which just calls minetest.chat_send_player() after prefixing msg with " -!- Mid-Measure : "
function tell_player(player_name, msg)
	minetest.chat_send_player(player_name, " -!- Mid-Measure : " .. msg)	
end

-- Register the marker tool used to mark pos1 and pos2
minetest.register_tool("mid_measure:marker", {
	description = "Mid-Measure Marker tool",
	inventory_image = "mid_measure_marker.png",
	stack_max = 1,
	liquids_pointable = true,
	
	-- On left-click
	on_use = function(itemstack, placer, pointed_thing)
	
		placer = placer:get_player_name()
		if pointed_thing.type == "node" then
		
			local pointed_node = minetest.get_node(pointed_thing.under).name
			if pointed_node == "mid_measure:pos1" or pointed_node == "mid_measure:pos2" or pointed_node == "mid_measure:midpoint" then
				reset(placer)
				return
			end
					
			-- If pos1 not marked, mark pos1
			if instances[placer].mark_status == none_set then
				mark_pos1(placer, pointed_thing.under)
			
			-- If pos1 marked, mark pos2 perform calculations, and trigger auto-reset
			elseif instances[placer].mark_status == pos1_set then
				mark_pos2(placer, pointed_thing.under)
				
			end
		end
		
		return itemstack
	end
})

-- Chat-command to mark pos1
minetest.register_chatcommand("mark1",{
	params = "",
	description = "Marks pos1 for Mid-Measure calculations.",
	privs = {interact = true},
	func = function(player, param)
		if instances[player].mark_status == none_set or instances[player].mark_status == pos1_set then
			mark_pos1(player, vector.round(minetest.get_player_by_name(player):get_pos()))
		elseif instances[player].mark_status > pos1_set then
			tell_player(player, "Use /reset_mark to reset and then use /mark1 again.")
		end
	end
})

-- Chat-command to mark pos2
minetest.register_chatcommand("mark2",{
	params = "",
	description = "Marks pos2 for Mid-Measure calculations.",
	privs = {interact = true},
	func = function(player, param)
		if instances[player].mark_status == pos1_set or instances[player].mark_status == pos2_set then
			mark_pos2(player, vector.round(minetest.get_player_by_name(player):get_pos()))
		elseif instances[player].mark_status > pos2_set then
			tell_player(player, "Use /reset_mark to reset, use /mark1 and then use /mark2 again.")
		end
	end
})

-- Chat-command to reset Mid-Measure calculations
minetest.register_chatcommand("reset_mark",{
	params = "",
	description = "Resets Mid-Measure calculation",
	privs = {interact = true},
	func = function(player_name, param)
		reset(player_name)
	end
})

-- Craft-recipe for marker (enabled only if mid_measure.enable_crafting == true)
if minetest.settings:get("mid_measure.enable_crafting") then
	minetest.register_craft({
		output = "mid_measure:marker",
		recipe = {
			{"default:mese_crystal_fragment"},
			{"default:stick"},
			{""}
		}
	})
end

-- Clear all marked nodes before shutdown
minetest.register_on_shutdown(function()
	for _, online_player in pairs(minetest.get_connected_players()) do
		reset(online_player:get_player_name())
	end
end)

