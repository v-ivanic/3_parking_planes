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
	for i=1,hlen do
		local tmp = redis.call("HVALS", 'hashPlanePlace')[i]
		redis.call("SADD", 'setOccupiedPlaces', tmp)
	end

	-- free parking spots
	-- it is necessary to delete set of free parking spots because
    -- spots can be occupied in every last run
	redis.call("DEL", 'setFree')
	for i=1,99 do
		local iSPlaceOccupied = redis.call("SISMEMBER", 'setOccupiedPlaces', i)
		if  0 == iSPlaceOccupied then
			redis.call("SADD", 'setFree', i)	
			-- break
		end
	end
	-- FOR can be breaked to speed up caluclation, no need to go through all parking places.
	-- 1 place is enough for 1 plane :)
	-- If requirement from task description (assign a random available parking spot)
	-- is absolutley neccessary, ommiting break will achieve it.
		
	-- random free place
	local freeParkingPlaceID = redis.call("SRANDMEMBER", 'setFree')
	redis.call("HSET", 'hashPlanePlace', ARGV[1], freeParkingPlaceID)
	ParkingSpotID = redis.call("HGET", 'hashPlanePlace', ARGV[1])
	return ParkingSpotID
end