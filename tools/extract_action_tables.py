import os
import struct

object_names = [
    "OBJECT_GEX",
    "OBJECT_BONUS_COIN",
    "OBJECT_FLY_COIN_SPAWN",
    "OBJECT_PAW_COIN",
    "OBJECT_FLY_1",
    "OBJECT_FLY_2",
    "OBJECT_FLY_3",
    "OBJECT_FLY_4",
    "OBJECT_FLY_5",
    "OBJECT_GREEN_FLY_TV",
    "OBJECT_PURPLE_FLY_TV",
    "OBJECT_UNK_FLY_TV_3",
    "OBJECT_BLUE_FLY_TV",
    "OBJECT_UNK_FLY_TV_5",
    "OBJECT_UNK0E",
    "OBJECT_UNK0F",
    "OBJECT_UNK10",
    "OBJECT_TV_BUTTON",
    "OBJECT_TV_REMOTE",
    "OBJECT_UNK13",
    "OBJECT_GOAL_COUNTER",
    "OBJECT_UNK15",
    "OBJECT_UNK16",
    "OBJECT_UNK17",
    "OBJECT_UNK18",
    "OBJECT_UNK19",
    "OBJECT_UNK1A",
    "OBJECT_BONUS_STAGE_TIMER",
    "OBJECT_FREESTANDING_REMOTE",
    "OBJECT_HOLIDAY_TV_ICE_SCULPTURE",
    "OBJECT_HOLIDAY_TV_EVIL_SANTA",
    "OBJECT_HOLIDAY_TV_EVIL_SANTA_PROJECTILE",
    "OBJECT_HOLIDAY_TV_SKATING_ELF",
    "OBJECT_HOLIDAY_TV_PENGUIN",
    "OBJECT_MYSTERY_TV_REZLING",
    "OBJECT_MYSTERY_TV_BLOOD_COOLER",
    "OBJECT_MYSTERY_TV_FISH",
    "OBJECT_MYSTERY_TV_MAGIC_SWORD",
    "OBJECT_MYSTERY_TV_SAFARI_SAM",
    "OBJECT_MYSTERY_TV_SAFARI_SAM_PROJECTILE",
    "OBJECT_MYSTERY_TV_GHOST_KNIGHT",
    "OBJECT_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE",
    "OBJECT_TUT_TV_HAND",
    "OBJECT_TUT_TV_LOST_ARK",
    "OBJECT_TUT_TV_RISING_PLATFORM",
    "OBJECT_TUT_TV_SIDEWAYS_PLATFORM",
    "OBJECT_TUT_TV_BEE",
    "OBJECT_TUT_TV_RAFT",
    "OBJECT_TUT_TV_SNAKE_FACING_RIGHT",
    "OBJECT_TUT_TV_SNAKE_FACING_LEFT",
    "OBJECT_TUT_TV_SNAKE_RIGHT_PROJECTILE",
    "OBJECT_TUT_TV_SNAKE_LEFT_PROJECTILE",
    "OBJECT_TUT_TV_RA_STAFF",
    "OBJECT_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE",
    "OBJECT_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE",
    "OBJECT_TUT_TV_BREAKABLE_BLOCK",
    "OBJECT_TUT_TV_COFFIN",
    "OBJECT_WESTERN_STATION_CACTUS",
    "OBJECT_UNK3A",
    "OBJECT_WESTERN_STATION_ROCK_PLATFORM",
    "OBJECT_WESTERN_STATION_HARD_HAT",
    "OBJECT_WESTERN_STATION_PLAYING_CARD",
    "OBJECT_WESTERN_STATION_BAT",
    "OBJECT_WESTERN_STATION_RISING_PLATFORM",
    "OBJECT_ANIME_CHANNEL_DOOR",
    "OBJECT_ANIME_CHANNEL_DOOR2",
    "OBJECT_ANIME_CHANNEL_FAN_LIFT",
    "OBJECT_ANIME_CHANNEL_MECH_FACING_RIGHT",
    "OBJECT_ANIME_CHANNEL_MECH_FACING_LEFT",
    "OBJECT_ANIME_CHANNEL_DISAPPEARING_FLOOR",
    "OBJECT_ANIME_CHANNEL_ON_SWITCH2",
    "OBJECT_ANIME_CHANNEL_ALIEN_CULTURE_TUBE",
    "OBJECT_ANIME_CHANNEL_BLUE_BEAM_BARRIER",
    "OBJECT_ANIME_CHANNEL_RISING_PLATFORM",
    "OBJECT_ANIME_CHANNEL_ON_SWITCH",
    "OBJECT_ANIME_CHANNEL_OFF_SWITCH",
    "OBJECT_ANIME_CHANNEL_SAILOR_TOON_GIRL",
    "OBJECT_ANIME_CHANNEL_BIG_SILVER_ROBOT",
    "OBJECT_ANIME_CHANNEL_SMALL_BLUE_ROBOT",
    "OBJECT_ANIME_CHANNEL_SECBOT",
    "OBJECT_ANIME_CHANNEL_SECBOT_PROJECTILE",
    "OBJECT_ANIME_CHANNEL_ELEVATOR",
    "OBJECT_ANIME_CHANNEL_FIRE_WALL_ENEMY",
    "OBJECT_ANIME_CHANNEL_GRENADE",
    "OBJECT_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON",
    "OBJECT_SUPERHERO_SHOW_MAD_BOMBER",
    "OBJECT_SUPERHERO_SHOW_BOMB",
    "OBJECT_SUPERHERO_SHOW_WATER_TOWER_TANK",
    "OBJECT_SUPERHERO_SHOW_WATER_TOWER_STAND",
    "OBJECT_SUPERHERO_SHOW_CONVICT",
    "OBJECT_SUPERHERO_SHOW_SPIDER",
    "OBJECT_SUPERHERO_SHOW_STRAY_CAT",
    "OBJECT_SUPERHERO_SHOW_YELLOW_GOON",
    "OBJECT_SUPERHERO_SHOW_RAT",
    "OBJECT_SUPERHERO_SHOW_CHOMPER_TV",
    "OBJECT_SUPERHERO_SHOW_CRUMBLING_FLOOR",
    "OBJECT_SUPERHERO_SHOW_CONVICT_PROJECTILE",
    "OBJECT_GEXTREME_SPORTS_ELF",
    "OBJECT_GEXTREME_SPORTS_BONUS_TIME_COIN",
    "OBJECT_MARSUPIAL_MADNESS_BELL",
    "OBJECT_MARSUPIAL_MADNESS_BIRD",
    "OBJECT_MARSUPIAL_MADNESS_BIRD_PROJECTILE",
    "OBJECT_WW_GEX_WRESTLING_ROCK_HARD",
    "OBJECT_LIZARD_OF_OZ_BRAIN_OF_OZ",
    "OBJECT_LIZARD_OF_OZ_CANNON_PROJECTILE",
    "OBJECT_LIZARD_OF_OZ_CANNON",
    "OBJECT_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE",
    "OBJECT_UNK6B",
    "OBJECT_UNK6C",
    "OBJECT_UNK6D",
    "OBJECT_CHANNEL_Z_REZ",
    "OBJECT_UNK6F",
    "OBJECT_CHANNEL_Z_METEOR",
    "OBJECT_CHANNEL_Z_REZ_PROJECTILE"
]

bank002_data = open('./banks/bank_002.bin', 'rb').read()

# get list of jump tables, starts at 0x4000
jump_table_list_data = bank002_data[0x0000:0x07b4]
#print(jump_table_list_data)

data_list_pointers = []

#first = True
i = 0
while i < len(object_names):
    jump_table_ptr = struct.unpack('<H',jump_table_list_data[0x0000 + 2*i:0x0000 + 2*i + 2])[0]
    #next_jump_table_ptr = struct.unpack('<H',jump_table_list_data[0x0000 + 2*(i+1):0x0000 + 2*(i+1) + 2])[0]
    #print("{:02x}".format(jump_table_ptr-0x4000)+", "+"{:02x}".format(next_jump_table_ptr-0x4000))
    
    print("    dw   .data_02_{:04x} ; {}".format(jump_table_ptr, object_names[i]))
    data_list_pointers.append(jump_table_ptr-0x4000)

    '''
    # old junk
    
    line_string = "data_02_{:02x}:                  ;; ".format(jump_table_ptr)
    #line_string += object_names[i]
    line_string += "\n"
    out.write(line_string)
    
    if first != True:
        curr_addr = jump_table_ptr
        while curr_addr < next_jump_table_ptr:
            #print("{:02x}".format(curr_addr-0x4000))
            func, data = struct.unpack('<HH',bank002_data[curr_addr-0x4000:curr_addr-0x4000+4])
            #print("{:02x}".format(func)+", "+"{:02x}".format(data))
            curr_addr = curr_addr + 4
            
            line_string = "    dw   ${:02x}, {:02x}\n".format(func, data)
            out.write(line_string)
            
            if data not in data_list_pointers:
                data_list_pointers.append(data)
            
    first = False'''
    i = i + 1


#out = open('./banks/object_actions.asm', "w")
#out.close()

data_pointers = []

for i in range(0x00e4, 0x07b4, 0x4):
    code, data = struct.unpack('<HH',jump_table_list_data[i:i+4])
    if data not in data_pointers:
        data_pointers.append(data)
    if i in data_list_pointers:
        print(".data_02_{:04x}:".format(i+0x4000))
    print("    dw   ${:04x}".format(code)+", data_02_{:04x}".format(data))


# print data with labels

data_pointers.append(0x7ef2) 
data_pointers.sort()

for i in range(0, len(data_pointers) - 1):
    data = bank002_data[data_pointers[i] - 0x4000 : data_pointers[i + 1] - 0x4000]
    print("data_02_{:04x}:".format(data_pointers[i]))

    # first 5 bytes
    first_chunk = data[:5]
    if first_chunk:
        print("    db   " + ", ".join(f"${byte:02x}" for byte in first_chunk))

    # everything else on second line
    remaining = data[5:]
    if remaining:
        print("    db   " + ", ".join(f"${byte:02x}" for byte in remaining))




'''
# old junk

data_list_pointers.sort()
#print(data_list_pointers)

out2 = open('./banks/action_data.asm', "w")

ptr_count = 0
while ptr_count < len(data_list_pointers):
    line_string = "data_02_{:02x}:\n".format(data_list_pointers[ptr_count])
    out2.write(line_string)

    data = bank002_data[data_list_pointers[ptr_count]-0x4000:data_list_pointers[ptr_count+1]-0x4000]
    print(data)
    line_string = "    db   " + ", ".join(f"${byte:02x}" for byte in data) + "\n"
    
    out2.write(line_string)
    ptr_count = ptr_count + 1

out2.close()
'''