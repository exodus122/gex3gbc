import os
import struct

object_names = [
    "Object_Gex",
    "Object_BonusCoin",
    "Object_FlyCoinSpawn",
    "Object_PawCoin",
    "Object_unk04",
    "Object_unk05",
    "Object_unk06",
    "Object_unk07",
    "Object_unk08",
    "Object_GreenFlyTV",
    "Object_PurpleFlyTV",
    "Object_unk0B",
    "Object_BlueFlyTV",
    "Object_unk0D",
    "Object_unk0E",
    "Object_unk0F",
    "Object_unk10",
    "Object_TVButton",
    "Object_TVRemote",
    "Object_unk13",
    "Object_GoalCounter",
    "Object_unk15",
    "Object_unk16",
    "Object_unk17",
    "Object_unk18",
    "Object_unk19",
    "Object_unk1A",
    "Object_BonusStageTimer",
    "Object_FreestandingRemote",
    "Object_HolidayTV_IceSculpture",
    "Object_HolidayTV_EvilSanta",
    "Object_HolidayTV_EvilSantaProjectile",
    "Object_HolidayTV_SkatingElf",
    "Object_HolidayTV_Penguin",
    "Object_MysteryTV_TVEnemy",
    "Object_MysteryTV_BloodCooler",
    "Object_MysteryTV_FishEnemy",
    "Object_MysteryTV_MagicSword",
    "Object_MysteryTV_GunnerEnemy",
    "Object_MysteryTV_GunnerBullet",
    "Object_MysteryTV_KnightBoss",
    "Object_MysteryTV_KnightBossProjectile",
    "Object_TutTV_Hand",
    "Object_TutTV_LostArk",
    "Object_TutTV_RisingPlatform",
    "Object_TutTV_SidewaysPlatform",
    "Object_TutTV_Bee",
    "Object_TutTV_Raft",
    "Object_TutTV_SnakeFacingRight",
    "Object_TutTV_SnakeFacingLeft",
    "Object_TutTV_SnakeRightProjectile",
    "Object_TutTV_SnakeLeftProjectile",
    "Object_TutTV_RaStaff",
    "Object_TutTV_RaStatueHorizontalProjectile",
    "Object_TutTV_RaStatueDiagonalProjectile",
    "Object_TutTV_BreakableBlock",
    "Object_TutTV_Coffin",
    "Object_WesternStation_Cactus",
    "Object_unk3A",
    "Object_WesternStation_RockPlatform",
    "Object_WesternStation_WalkerEnemy",
    "Object_WesternStation_PlayingCard",
    "Object_WesternStation_Bat",
    "Object_WesternStation_RisingPlatform",
    "Object_AnimeChannel_Door",
    "Object_AnimeChannel_Door2",
    "Object_AnimeChannel_FanLift",
    "Object_AnimeChannel_MechFacingRight",
    "Object_AnimeChannel_MechFacingLeft",
    "Object_AnimeChannel_DisappearingFloor",
    "Object_AnimeChannel_OnSwitch2",
    "Object_AnimeChannel_AlienCultureTube",
    "Object_AnimeChannel_BlueBeamBarrier",
    "Object_AnimeChannel_RisingPlatform",
    "Object_AnimeChannel_OnSwitch",
    "Object_AnimeChannel_OffSwitch",
    "Object_AnimeChannel_PinkGirl",
    "Object_AnimeChannel_BigSilverRobot",
    "Object_AnimeChannel_SmallBlueRobot",
    "Object_AnimeChannel_TransformerEnemy",
    "Object_AnimeChannel_TransformerEnemyProjectile",
    "Object_AnimeChannel_Elevator",
    "Object_AnimeChannel_FireWallEnemy",
    "Object_AnimeChannel_FallingYellowEnemy",
    "Object_AnimeChannel_PlanetOBlastWeapon",
    "Object_SuperheroShow_MadBomber",
    "Object_SuperheroShow_Bomb",
    "Object_SuperheroShow_WaterTowerTank",
    "Object_SuperheroShow_WaterTowerStand",
    "Object_SuperheroShow_Convict",
    "Object_SuperheroShow_Spider",
    "Object_SuperheroShow_StrayCat",
    "Object_SuperheroShow_YellowGoon",
    "Object_SuperheroShow_Rat",
    "Object_SuperheroShow_FlyingRobotHead",
    "Object_SuperheroShow_FalseFloor",
    "Object_SuperheroShow_GreyConvictProjectile",
    "Object_GextremeSports_Elf",
    "Object_GextremeSports_BonusTimeCoin",
    "Object_MarsupialMadness_Bell",
    "Object_MarsupialMadness_Bird",
    "Object_MarsupialMadness_BirdProjectile",
    "Object_WWGexWrestling_RockHard",
    "Object_LizardOfOz_BrainOfOz",
    "Object_LizardOfOz_CannonProjectile",
    "Object_LizardOfOz_Cannon",
    "Object_LizardOfOz_RockProjectile",
    "Object_unk6B",
    "Object_unk6C",
    "Object_unk6D",
    "Object_ChannelZ_Rez",
    "Object_unk6F",
    "Object_ChannelZ_Meteor",
    "Object_ChannelZ_RockProjectile"
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

'''
# print data with labels

data_pointers.append(0x7ef2)
data_pointers.sort()
for i in range(0, len(data_pointers) - 1):
    data = bank002_data[data_pointers[i] - 0x4000 : data_pointers[i + 1] - 0x4000]
    print("data_02_{:04x}:".format(data_pointers[i]))
    for j in range(0, len(data), 8):
        chunk = data[j:j+8]
        line_string = "    db   " + ", ".join(f"${byte:02x}" for byte in chunk)
        print(line_string)
'''




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