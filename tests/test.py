import subprocess
import redis
import random


def check_duplicates(plane_ids, path_to_script):
    parking_spot_ids = set()
    for planeID in plane_ids:
        # TO DO: switch from subprocess to redis
        parking_spot_id = subprocess.check_output(['redis-cli', '--eval', path_to_script, ',', str(planeID)])
        parking_spot_id = (parking_spot_id.decode('utf-8')).rstrip('\n')
        if parking_spot_id in parking_spot_ids:
            print('Found duplicate.')
            return False
        parking_spot_ids.add(parking_spot_id)
    print('parking_spot_ids:\n' + str(parking_spot_ids))
    print('Number of parking_spot_ids: ' + str(len(parking_spot_ids)))
    print('Didn\'t find duplicate.')
    return True


rconn = redis.Redis()
orderedPlaneIDs = list(range(1, 81))
shuffledPlaneIDs = list(range(1, 81))
random.shuffle(shuffledPlaneIDs)
planeIDss = [orderedPlaneIDs, shuffledPlaneIDs]

path_1 = '../src/parking_planes_lua_list.lua'
path_2 = '../src/parking_planes_redis_sets.lua'
paths = [path_1, path_2]

for planeIDs in planeIDss:
    for path in paths:
        # clear redis DB before testing
        # BE CAREFUL AS THIS WILL CLEAR ALL EXISTING REDIS DBs ON MACHINE
        # TO DO: do not use flushall(), but clear hashes and sets used explicitly in lua scripts
        rconn.flushall()
        duplicatesNotFound = check_duplicates(planeIDs, path)
        if duplicatesNotFound:
            print('OK for planeIDs:\n' + str(planeIDs) + '\nand path:\n' + str(path) + '\n')
        else:
            print('Failed for planeIDs:\n' + str(planeIDs) + '\nand path:\n' + str(path) + '\n')
