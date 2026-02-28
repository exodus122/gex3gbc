import os
import struct

entity_names = [
    "ENTITY_GEX",
    "ENTITY_BONUS_COIN",
    "ENTITY_FLY_COIN_SPAWN",
    "ENTITY_PAW_COIN",
    "ENTITY_FLY_1",
    "ENTITY_FLY_2",
    "ENTITY_FLY_3",
    "ENTITY_FLY_4",
    "ENTITY_FLY_5",
    "ENTITY_GREEN_FLY_TV",
    "ENTITY_PURPLE_FLY_TV",
    "ENTITY_UNK_FLY_TV_3",
    "ENTITY_BLUE_FLY_TV",
    "ENTITY_UNK_FLY_TV_5",
    "ENTITY_UNK0E",
    "ENTITY_UNK0F",
    "ENTITY_UNK10",
    "ENTITY_TV_BUTTON",
    "ENTITY_TV_REMOTE",
    "ENTITY_UNK13",
    "ENTITY_GOAL_COUNTER_1",
    "ENTITY_GOAL_COUNTER_2",
    "ENTITY_GOAL_COUNTER_3",
    "ENTITY_GOAL_COUNTER_4",
    "ENTITY_GOAL_COUNTER_5",
    "ENTITY_GOAL_COUNTER_6",
    "ENTITY_GOAL_COUNTER_7",
    "ENTITY_BONUS_STAGE_TIMER",
    "ENTITY_FREESTANDING_REMOTE",
    "ENTITY_HOLIDAY_TV_ICE_SCULPTURE",
    "ENTITY_HOLIDAY_TV_EVIL_SANTA",
    "ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE",
    "ENTITY_HOLIDAY_TV_SKATING_ELF",
    "ENTITY_HOLIDAY_TV_PENGUIN",
    "ENTITY_MYSTERY_TV_REZLING",
    "ENTITY_MYSTERY_TV_BLOOD_COOLER",
    "ENTITY_MYSTERY_TV_FISH",
    "ENTITY_MYSTERY_TV_MAGIC_SWORD",
    "ENTITY_MYSTERY_TV_SAFARI_SAM",
    "ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE",
    "ENTITY_MYSTERY_TV_GHOST_KNIGHT",
    "ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE",
    "ENTITY_TUT_TV_HAND",
    "ENTITY_TUT_TV_LOST_ARK",
    "ENTITY_TUT_TV_RISING_PLATFORM",
    "ENTITY_TUT_TV_SIDEWAYS_PLATFORM",
    "ENTITY_TUT_TV_BEE",
    "ENTITY_TUT_TV_RAFT",
    "ENTITY_TUT_TV_SNAKE_FACING_RIGHT",
    "ENTITY_TUT_TV_SNAKE_FACING_LEFT",
    "ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE",
    "ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE",
    "ENTITY_TUT_TV_RA_STAFF",
    "ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE",
    "ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE",
    "ENTITY_TUT_TV_BREAKABLE_BLOCK",
    "ENTITY_TUT_TV_COFFIN",
    "ENTITY_WESTERN_STATION_ENEMY_CACTUS",
    "ENTITY_WESTERN_STATION_CACTUS",
    "ENTITY_WESTERN_STATION_ROCK_PLATFORM",
    "ENTITY_WESTERN_STATION_HARD_HAT",
    "ENTITY_WESTERN_STATION_PLAYING_CARD",
    "ENTITY_WESTERN_STATION_BAT",
    "ENTITY_WESTERN_STATION_RISING_PLATFORM",
    "ENTITY_ANIME_CHANNEL_DOOR",
    "ENTITY_ANIME_CHANNEL_DOOR2",
    "ENTITY_ANIME_CHANNEL_FAN_LIFT",
    "ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT",
    "ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT",
    "ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR",
    "ENTITY_ANIME_CHANNEL_ON_SWITCH2",
    "ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE",
    "ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER",
    "ENTITY_ANIME_CHANNEL_RISING_PLATFORM",
    "ENTITY_ANIME_CHANNEL_ON_SWITCH",
    "ENTITY_ANIME_CHANNEL_OFF_SWITCH",
    "ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL",
    "ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT",
    "ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT",
    "ENTITY_ANIME_CHANNEL_SECBOT",
    "ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE",
    "ENTITY_ANIME_CHANNEL_ELEVATOR",
    "ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY",
    "ENTITY_ANIME_CHANNEL_GRENADE",
    "ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON",
    "ENTITY_SUPERHERO_SHOW_MAD_BOMBER",
    "ENTITY_SUPERHERO_SHOW_BOMB",
    "ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK",
    "ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND",
    "ENTITY_SUPERHERO_SHOW_CONVICT",
    "ENTITY_SUPERHERO_SHOW_SPIDER",
    "ENTITY_SUPERHERO_SHOW_STRAY_CAT",
    "ENTITY_SUPERHERO_SHOW_YELLOW_GOON",
    "ENTITY_SUPERHERO_SHOW_RAT",
    "ENTITY_SUPERHERO_SHOW_CHOMPER_TV",
    "ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR",
    "ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE",
    "ENTITY_GEXTREME_SPORTS_ELF",
    "ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN",
    "ENTITY_MARSUPIAL_MADNESS_BELL",
    "ENTITY_MARSUPIAL_MADNESS_BIRD",
    "ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE",
    "ENTITY_WW_GEX_WRESTLING_ROCK_HARD",
    "ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ",
    "ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE",
    "ENTITY_LIZARD_OF_OZ_CANNON",
    "ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE",
    "ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2",
    "ENTITY_CHANNEL_Z_GREEN_BLOCK",
    "ENTITY_CHANNEL_Z_ORANGE_BLOCK",
    "ENTITY_CHANNEL_Z_REZ",
    "ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER",
    "ENTITY_CHANNEL_Z_METEOR",
    "ENTITY_CHANNEL_Z_REZ_PROJECTILE"
]

bank002_data = open('./banks/bank_002.bin', 'rb').read()

# get list of jump tables, starts at 0x4000
jump_table_list_data = bank002_data[0x0000:0x07b4]
#print(jump_table_list_data)

data_list_pointers = []

#first = True
i = 0
while i < len(entity_names):
    jump_table_ptr = struct.unpack('<H',jump_table_list_data[0x0000 + 2*i:0x0000 + 2*i + 2])[0]
    #next_jump_table_ptr = struct.unpack('<H',jump_table_list_data[0x0000 + 2*(i+1):0x0000 + 2*(i+1) + 2])[0]
    #print("{:02x}".format(jump_table_ptr-0x4000)+", "+"{:02x}".format(next_jump_table_ptr-0x4000))
    
    print("    dw   .data_02_{:04x} ; {}".format(jump_table_ptr, entity_names[i]))
    data_list_pointers.append(jump_table_ptr-0x4000)

    '''
    # old junk
    
    line_string = "data_02_{:02x}:                  ;; ".format(jump_table_ptr)
    #line_string += entity_names[i]
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


#out = open('./banks/entity_actions.asm', "w")
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