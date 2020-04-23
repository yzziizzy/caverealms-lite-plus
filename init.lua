caverealms = {} --create a container for functions and constants

--grab a shorthand for the filepath of the mod
local modpath = minetest.get_modpath(minetest.get_current_modname())
--[[
-- debug privileges
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	
	local privs = minetest.get_player_privs(name)

	privs.fly = true
	privs.fast = true
	privs.teleport = true
	privs.noclip = true
	minetest.set_player_privs(name, privs)
	
	local p = player:get_pos()
	if p.y > -100 then
		player:set_pos({x=0, y=-20000, z= 0})
	end
end)
]]


--load companion lua files
dofile(modpath.."/config.lua") --configuration file; holds various constants
dofile(modpath.."/crafting.lua") --crafting recipes
dofile(modpath.."/nodes.lua") --node definitions
dofile(modpath.."/functions.lua") --function definitions
dofile(modpath.."/plants.lua")
dofile(modpath.."/hotsprings.lua")

if minetest.get_modpath("mobs_monster") then
	if caverealms.config.dm_spawn == true then
		dofile(modpath.."/dungeon_master.lua") --special DMs for DM's Lair biome
	end
end

-- Parameters

local YMIN = caverealms.config.ymin -- Approximate realm limits.
local YMAX = caverealms.config.ymax
local TCAVE = caverealms.config.tcave --0.5 -- Cave threshold. 1 = small rare caves, 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume
local BLEND = 128 -- Cave blend distance near YMIN, YMAX

local STAGCHA = caverealms.config.stagcha --0.002 --chance of stalagmites
local STALCHA = caverealms.config.stalcha --0.003 --chance of stalactites
local CRYSTAL = caverealms.config.crystal --0.0004 --chance of glow crystal formations
local SALTCRYCHA = caverealms.config.salt_crystal --0.007 --chance of salt crystal cubes
local GEMCHA = caverealms.config.gemcha --0.03 --chance of small glow gems
local HOTSCHA = 0.009 --chance of hotsprings
local MUSHCHA = caverealms.config.mushcha --0.04 --chance of mushrooms
local MYCCHA = caverealms.config.myccha --0.03 --chance of mycena mushrooms
local WORMCHA = caverealms.config.wormcha --0.03 --chance of glow worms
local GIANTCHA = caverealms.config.giantcha --0.001 -- chance of giant mushrooms
local ICICHA = caverealms.config.icicha --0.035 -- chance of icicles
local FLACHA = caverealms.config.flacha --0.04 --chance of constant flames

local DM_TOP = caverealms.config.dm_top -- -4000 --level at which Dungeon Master Realms start to appear
local DM_BOT = caverealms.config.dm_bot -- -5000 --level at which "" ends
local DEEP_CAVE = caverealms.config.deep_cave -- -7000 --level at which deep cave biomes take over

-- 2D noise for biome

local np_biome_evil = {
	offset = 0,
	scale = 1,
	spread = {x=200, y=200, z=200},
	seed = 9130,
	octaves = 3,
	persist = 0.5
}

local np_biome_wonder = {
	offset = 0,
	scale = 1,
	spread = {x=400, y=400, z=400},
	seed = 8943,
	octaves = 2,
	persist = 0.45
}

-- Stuff

subterrain = {}


-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	--if out of range of caverealms limits
	if minp.y > YMAX or maxp.y < YMIN then
		return --quit; otherwise, you'd have stalagmites all over the place
	end

	--easy reference to commonly used values
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	--print ("[caverealms] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	--grab content IDs
	local c_air = minetest.get_content_id("air")
	local c_stone = minetest.get_content_id("default:stone")
	
	local c_water = minetest.get_content_id("default:water_source")
	local c_lava = minetest.get_content_id("default:lava_source")
	local c_ice = minetest.get_content_id("default:ice")
	local c_thinice = minetest.get_content_id("caverealms:thin_ice")
	local c_crystal = minetest.get_content_id("caverealms:glow_crystal")
	local c_gem = minetest.get_content_id("caverealms:glow_gem")
	local c_saltgem = minetest.get_content_id("caverealms:salt_gem")
	local c_spike = minetest.get_content_id("caverealms:spike")
	local c_moss = minetest.get_content_id("caverealms:stone_with_moss")
	local c_lichen = minetest.get_content_id("caverealms:stone_with_lichen")
	local c_algae = minetest.get_content_id("caverealms:stone_with_algae")
	local c_salt = minetest.get_content_id("caverealms:stone_with_salt")
	local c_hcobble = minetest.get_content_id("caverealms:hot_cobble")
	local c_gobsidian = minetest.get_content_id("caverealms:glow_obsidian")
	local c_gobsidian2 = minetest.get_content_id("caverealms:glow_obsidian_2")
	local c_coalblock = minetest.get_content_id("default:coalblock")
	local c_desand = minetest.get_content_id("default:desert_sand")
	local c_coaldust = minetest.get_content_id("caverealms:coal_dust")
	local c_fungus = minetest.get_content_id("caverealms:fungus")
	local c_mycena = minetest.get_content_id("caverealms:mycena")
	local c_worm_blue = minetest.get_content_id("caverealms:glow_worm")
	local c_worm_green = minetest.get_content_id("caverealms:glow_worm_green")
	local c_worm_red = minetest.get_content_id("caverealms:glow_worm_red")
	local c_fire_vine = minetest.get_content_id("caverealms:fire_vine")
	local c_iciu = minetest.get_content_id("caverealms:icicle_up")
	local c_icid = minetest.get_content_id("caverealms:icicle_down")
	local c_flame = minetest.get_content_id("caverealms:constant_flame")
	local c_bflame = minetest.get_content_id("caverealms:constant_flame_blue")
	local c_firefly = minetest.get_content_id("fireflies:firefly")
	
	-- crystals
	local c_crystore = minetest.get_content_id("caverealms:glow_ore")
	local c_emerald = minetest.get_content_id("caverealms:glow_emerald")
	local c_emore = minetest.get_content_id("caverealms:glow_emerald_ore")
	local c_mesecry = minetest.get_content_id("caverealms:glow_mese")
	local c_meseore = minetest.get_content_id("default:stone_with_mese")
	local c_ruby = minetest.get_content_id("caverealms:glow_ruby")
	local c_rubore = minetest.get_content_id("caverealms:glow_ruby_ore")
	local c_citrine = minetest.get_content_id("caverealms:glow_citrine")
	local c_citore = minetest.get_content_id("caverealms:glow_citrine_ore")
	local c_ameth = minetest.get_content_id("caverealms:glow_amethyst")
	local c_amethore = minetest.get_content_id("caverealms:glow_amethyst_ore")
	local c_hotspring = minetest.get_content_id("caverealms:hotspring_water_source")

	
	--mandatory values
	local sidelen = x1 - x0 + 1 --length of a mapblock
	local chulens = {x=sidelen, y=sidelen, z=sidelen} --table of chunk edges
	local chulens2D = {x=sidelen, y=sidelen, z=1}
	local minposxyz = {x=x0, y=y0, z=z0} --bottom corner
	local minposxz = {x=x0, y=z0} --2D bottom corner
	
	
	--[[
	wonder:   low    ------------->    high
	
	low-evil: algae moss lichen
	mid-evil:  desert salt glacial
	high-evil: hotsprings dungeon deep-glacial  
	
	
	
	deep-glacial: blue flame
	desert: constant flame
	
	]]
	
	
	
	
	local nvals_biome_e = minetest.get_perlin_map(np_biome_evil, chulens2D):get2dMap_flat({x=x0+150, y=z0+50}) --2D noise for biomes (will be 3D humidity/temp later)
	local nvals_biome_w = minetest.get_perlin_map(np_biome_wonder, chulens2D):get2dMap_flat({x=x0+150, y=z0+50}) --2D noise for biomes (will be 3D humidity/temp later)
	
	
	local nixyz = 1 --3D node index
	local nixz = 1 --2D node index
	local nixyz2 = 1 --second 3D index for second loop
	

	for z = z0, z1 do -- for each xy plane progressing northwards
		--increment indices
		nixyz = nixyz + 1


		--decoration loop
		for y = y0, y1 do -- for each x row progressing upwards
		
			local is_deep = false
			if y < DEEP_CAVE then
				is_deep = true
			end
		

			local vi = area:index(x0, y, z)
			for x = x0, x1 do -- for each node do
				
				--determine biome
				local biome = 0 --preliminary declaration
				local n_biome_e = nvals_biome_e[nixz]   --make an easier reference to the noise
				local n_biome_w = nvals_biome_w[nixz]   --make an easier reference to the noise
				local n_biome = (n_biome_e + n_biome_w) / 2
				
				local floor = c_hcobble
				local floor_depth = 1
				local worms = {}
				local worm_max_len = 1
				local no_mites = false
				local no_tites = false
				local do_hotspring = false
				local decos = {}
				local decos2 = {}
				local deco_mul = 1
				
				local wiggle = (math.random() - 0.5) / 20
				n_biome_e = n_biome_e + wiggle
				n_biome_w = n_biome_w + wiggle
				
				if n_biome_e < -0.33 then
					if n_biome_w < -0.33 then -- algae
						floor = c_algae
						worms = {c_worm_green}
						worm_max_len = 3
						decos = {c_mycena, c_firefly}
					elseif n_biome_w < 0.33 then -- moss
						floor = c_moss
						worms = {c_worm_green, c_worm_blue}
						worm_max_len = 3
						decos = {c_mycena}
						deco_mul = 2.0
					else -- lichen
						floor = c_lichen
						worms = {c_worm_blue}
						worm_max_len = 3
						decos = {c_mycena, c_fungus, c_fungus}
						deco_mul = 3.3
					end
				elseif n_biome_e < 0.33 then
					if n_biome_w < -0.33 then -- desert
						
						if math.random() < 0.05 then
							floor = c_coalblock
						elseif math.random() < 0.15 then
							floor = c_coaldust
						else
							floor = c_desand
						end
						floor_depth = 2
						
						worms = {c_worm_red}
						worm_max_len = 1
						decos = {c_flame, c_spike}
					elseif n_biome_w < 0.33 then -- salt
						floor = c_salt
						floor_depth = 2
						worms = {c_icid}
						worm_max_len = 1
						no_mites = true
						
						decos = {c_saltgem}
					else -- glacial
						floor = c_thinice
						floor_depth = 2
						worms = {c_icid}
						worm_max_len = 1
						
						decos = {c_gem}
					end
				else
					if n_biome_w < -0.33 then -- hotspring
						floor = c_hcobble
						worms = {c_icid}
						worm_max_len = 1
						if math.random() < 0.005 then
							do_hotspring = true
						end
						decos = {c_fire_vine}
						deco_mul = 0.7
					elseif n_biome_w < 0.33 then -- dungeon
						if math.random() < 0.5 then
							floor = c_gobsidian
						else
							floor = c_gobsidian2
						end
						worms = {c_worm_red}
						worm_max_len = 4
						decos = {c_flame, c_flame, c_fire_vine}
					else -- deep glacial
						floor = c_ice
						floor_depth = 3
						worms = {c_icid}
						worm_max_len = 1
						
						decos = {c_bflame}
					end
				end
				
				
				
				
				local ai = area:index(x,y+1,z) --above index
				local bi = area:index(x,y-1,z) --below index
				
				
				-- place floor
				if data[bi] == c_stone and data[vi] == c_air then --ground
					for i = 1,floor_depth do
						local ii = area:index(x,y-i,z)
						if data[ii] == c_stone then
							data[ii] = floor
						end
					end
					
					if do_hotspring == true then
						caverealms:spawn_hotspring(x,y,z, area, data, math.random(4) + 2)
					end
					
					-- decorations
					if math.random() < ICICHA * deco_mul and data[bi] ~= c_hotspring then
						data[vi] = decos[math.random(1, #decos)]
					end
					
					-- salt crystals
					if floor == c_salt and math.random() < SALTCRYCHA then
						caverealms:salt_stalagmite(x,y,z, area, data)
					end
					
					-- stone stalagmites
					if math.random() < STAGCHA then
						caverealms:stalagmite(x,y,z, area, data)
					end
					
					-- crystal stalagmites
					if not no_mites and math.random() < CRYSTAL then
						local ore
						local cry
						
						if n_biome_e < 0 then -- non-evil
							if n_biome_w < -0.33 then
								ore = c_crystore
								cry = c_crystal
							elseif n_biome_w < 0.33 then
								ore = c_emore
								cry = c_emerald
							else
								ore = c_amethore
								cry = c_ameth
							end
						elseif n_biome_e < 0.4 then -- moderately evil 
							if n_biome_w < 0 then
								ore = c_meseore
								cry = c_mesecry
							else
								ore = c_citore
								cry = c_citrine
							end
						else -- very evil
							ore = c_rubore
							cry = c_ruby
						end
						
						local base = floor
						caverealms:crystal_stalagmite(x,y,z, area, data, ore, cry, base)
					end
					
					
					if n_biome_w > 0.5 and n_biome_e < -0.33 and math.random() < GIANTCHA then --giant mushrooms
						caverealms:giant_shroom(x, y, z, area, data)
					end
					
					-- temporary light
					if math.random() < FLACHA then --neverending flames
						--data[vi] = c_flame
					end
				end
				
				-- place ceiling
				if data[ai] == c_stone and data[vi] == c_air and y < y1 then
					if math.random() < ICICHA then
						local worm = worms[math.random(1,#worms)]
						local wdepth = math.random(1, worm_max_len)
						for i = 0,wdepth-1 do
							local ii = area:index(x,y-i,z)
							if data[ii] == c_air then
								data[ii] = worm
							end
						end
					end
					
					
					-- stalactites
					if not no_tites and math.random() < CRYSTAL then
						local ore
						local cry
						
						if n_biome_e < 0 then -- non-evil
							if n_biome_w < -0.33 then
								ore = c_crystore
								cry = c_crystal
							elseif n_biome_w < 0.33 then
								ore = c_emore
								cry = c_emerald
							else
								ore = c_amethore
								cry = c_ameth
							end
						elseif n_biome_e < 0.4 then -- moderately evil 
							if n_biome_w < 0 then
								ore = c_meseore
								cry = c_mesecry
							else
								ore = c_citore
								cry = c_citrine
							end
						else -- very evil
							ore = c_rubore
							cry = c_ruby
						end
						
						local base = c_stone
						caverealms:crystal_stalactite(x,y,z, area, data, ore, cry, base)
					end
					
				end
				
				
				nixyz2 = nixyz2 + 1
				nixz = nixz + 1
				vi = vi + 1
			end
			nixz = nixz - sidelen --shift the 2D index back
		end
		nixz = nixz + sidelen --shift the 2D index up a layer
	end

	--send data back to voxelmanip
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	--write it to world
	vm:write_to_map(data)

	--local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	--print ("[caverealms] "..chugent.." ms") --tell people how long
end)
print("[caverealms] loaded!")
