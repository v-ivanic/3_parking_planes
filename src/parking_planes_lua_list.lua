-- used for debugging 
local logtable = {}
local function logit(msg)
	logtable[#logtable+1] = msg
end

-- would be good to limit input range as in task description
local plane_parked = redis.call("HEXISTS", 'hashPlanePlace', ARGV[1])
local ParkingSpotID

if 0 ~= plane_parked then
    -- return parking place ID if assigned
	ParkingSpotID = redis.call("HGET", 'hashPlanePlace', ARGV[1])
	return ParkingSpotID
else
	-- assign parking place ID if unassigned
	-- occupied parking spots
	local hlen = redis.call("HLEN", 'hashPlanePlace')
	local arrayOccupiedPlaces = {}
	for i=1,hlen do
		arrayOccupiedPlaces[i] = redis.call("HVALS", 'hashPlanePlace')[i]
	end
	
	-- free parking spots
	local arrayFreePlaces = {}	
	for i=1,99 do
		local is_place_free = true
		for index, value in ipairs(arrayOccupiedPlaces) do	
			if tonumber(value) == i then
				is_place_free = false
			end	
		end
		if is_place_free == true then
			local index_free = table.getn(arrayFreePlaces) + 1
			arrayFreePlaces[index_free] = i
			-- brake
		end
	end
	-- FOR can be breaked to speed up caluclation, no need to go through all parking places.
	-- 1 place is enough for 1 plane :)
	-- If requirement from task description (assign a random available parking spot)
	-- is absolutley neccessary, ommiting break will achieve it.
	
	-- random free place
	local len_free_places = table.getn(arrayFreePlaces)
	local random_seed = redis.call("TIME")[2]
	math.randomseed(random_seed)
	local index_free = math.random(1, len_free_places)
	local freeParkingPlaceID = arrayFreePlaces[index_free]
	redis.call("HSET", 'hashPlanePlace', ARGV[1], freeParkingPlaceID)	
	ParkingSpotID = redis.call("HGET", 'hashPlanePlace', ARGV[1])
	return ParkingSpotID
end