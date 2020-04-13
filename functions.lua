local H_LAG = caverealms.config.h_lag --15 --max height for stalagmites
local H_LAC = caverealms.config.h_lac --20 --...stalactites
local H_CRY = caverealms.config.h_cry --9 --max height of glow crystals
local H_CLAC = caverealms.config.h_clac --13 --max height of glow crystal stalactites

function caverealms:above_solid(x,y,z,area,data)
	local c_air = minetest.get_content_id("air")

	local ai = area:index(x,y+1,z-3)
	if data[ai] == c_air then
		return false
	else
		return true
	end
end

function caverealms:below_solid(x,y,z,area,data)
	local c_air = minetest.get_content_id("air")

	local ai = area:index(x,y-1,z-3)
	if data[ai] == c_air then
		return false
	else
		return true
	end
end

--stalagmite spawner
function caverealms:stalagmite(x,y,z, area, data)

	if not caverealms:below_solid(x,y,z,area,data) then
		return
	end
	
	--contest ids
	local c_stone = minetest.get_content_id("default:stone")

	local top = math.random(6,H_LAG) --grab a random height for the stalagmite
	for j = 0, top do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j == 0 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = c_stone
					end
				elseif j <= top/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = c_stone
					end
				elseif j <= top/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = c_stone
					end
				else
					local vi = area:index(x, y+j, z-3)
					data[vi] = c_stone
				end
			end
		end
	end
end

--stalactite spawner
function caverealms:stalactite(x,y,z, area, data)

	if not caverealms:above_solid(x,y,z,area,data) then
		return
	end

	--contest ids
	local c_stone = minetest.get_content_id("default:stone")--("caverealms:limestone")

	local bot = math.random(-H_LAC, -6) --grab a random height for the stalagmite
	for j = bot, 0 do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j >= -1 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = c_stone
					end
				elseif j >= bot/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = c_stone
					end
				elseif j >= bot/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = c_stone
					end
				else
					local vi = area:index(x, y+j, z-3)
					data[vi] = c_stone
				end
			end
		end
	end
end

--glowing crystal stalagmite spawner
function caverealms:crystal_stalagmite(x,y,z, area, data, ore, crystal, base)

	if not caverealms:below_solid(x,y,z,area,data) then
		return
	end
	
	--contest ids
	local c_stone = minetest.get_content_id("default:stone")

 	local nid_a = ore -- ore
 	local nid_b = crystal -- crystal
	local nid_s = base or c_stone --base  --stone base, will be rewritten to ice in certain biomes

	local top = math.random(5,H_CRY) --grab a random height for the stalagmite
	for j = 0, top do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j == 0 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = nid_s
					end
				elseif j <= top/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = nid_a
					end
				elseif j <= top/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = nid_b
					end
				else
					local vi = area:index(x, y+j, z-3)
					data[vi] = nid_b
				end
			end
		end
	end
end

--crystal stalactite spawner
function caverealms:crystal_stalactite(x,y,z, area, data, ore, cry, base)

	if not caverealms:above_solid(x,y,z,area,data) then
		return
	end

	--contest ids
	local c_stone = minetest.get_content_id("default:stone")
	
 	local nid_a = ore
 	local nid_b = cry
	local nid_s = base or c_stone --stone base, will be rewritten to ice in certain biomes

	local bot = math.random(-H_CLAC, -6) --grab a random height for the stalagmite
	for j = bot, 0 do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j >= -1 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = nid_s
					end
				elseif j >= bot/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = nid_a
					end
				elseif j >= bot/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = nid_b
					end
				else
					local vi = area:index(x, y+j, z-3)
					data[vi] = nid_b
				end
			end
		end
	end
end

--glowing crystal stalagmite spawner
function caverealms:salt_stalagmite(x,y,z, area, data)

	if not caverealms:below_solid(x,y,z,area,data) then
		return
	end
	
	--contest ids
-- 	local c_stone = minetest.get_content_id("default:stone")
	local c_salt = minetest.get_content_id("caverealms:salt_crystal")
	local c_salt_stone = minetest.get_content_id("caverealms:stone_with_salt")
	
	local scale = math.random(2, 4)
	if scale == 2 then
		for j = -3, 3 do
			for k = -3, 3 do
				local vi = area:index(x+j, y, z+k)
				data[vi] = c_salt_stone
				if math.abs(j) ~= 3 and math.abs(k) ~= 3 then
					local vi = area:index(x+j, y+1, z+k)
					data[vi] = c_salt_stone
				end
			end
		end
	else
		for j = -4, 4 do
			for k = -4, 4 do
				local vi = area:index(x+j, y, z+k)
				data[vi] = c_salt_stone
				if math.abs(j) ~= 4 and math.abs(k) ~= 4 then
					local vi = area:index(x+j, y+1, z+k)
					data[vi] = c_salt_stone
				end
			end
		end
	end
	for j = 2, scale + 2 do --y
		for k = -2, scale - 2 do
			for l = -2, scale - 2 do
				local vi = area:index(x+k, y+j, z+l)
				data[vi] = c_salt -- make cube
			end
		end
	end
end

--function to create giant 'shrooms
function caverealms:giant_shroom(x, y, z, area, data)

	if not caverealms:below_solid(x,y,z,area,data) then
		return
	end

	local c_cap
	local c_stem

	--as usual, grab the content ID's
	if minetest.get_modpath("ethereal") then
		c_stem = minetest.get_content_id("ethereal:mushroom_trunk")
		c_cap = minetest.get_content_id("ethereal:mushroom")
	else
		c_stem = minetest.get_content_id("caverealms:mushroom_stem")
		c_cap = minetest.get_content_id("caverealms:mushroom_cap")
	end
	
	local c_gills = minetest.get_content_id("caverealms:mushroom_gills")

	z = z - 5
	--cap
	for k = -5, 5 do
	for l = -5, 5 do
		if k*k + l*l <= 25 then
			local vi = area:index(x+k, y+5, z+l)
			data[vi] = c_cap
		end
		if k*k + l*l <= 16 then
			local vi = area:index(x+k, y+6, z+l)
			data[vi] = c_cap
			vi = area:index(x+k, y+5, z+l)
			data[vi] = c_gills
		end
		if k*k + l*l <= 9 then
			local vi = area:index(x+k, y+7, z+l)
			data[vi] = c_cap
		end
		if k*k + l*l <= 4 then
			local vi = area:index(x+k, y+8, z+l)
			data[vi] = c_cap
		end
	end
	end
	--stem
	for j = 0, 5 do
		for k = -1,1 do
			local vi = area:index(x+k, y+j, z)
			data[vi] = c_stem
			if k == 0 then
				local ai = area:index(x, y+j, z+1)
				data[ai] = c_stem
				ai = area:index(x, y+j, z-1)
				data[ai] = c_stem
			end
		end
	end
end
