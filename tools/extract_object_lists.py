import os
import struct

levels = [
    # channel, level_name, start_level_addr, next_level_addr
    ["media_dimension", "media_dimension", 0x4057, 0x4488],
    ["toon_tv", "out_of_toon", 0x4488, 0x48c9],
    ["scream_tv", "smellraiser", 0x48c9, 0x4aba],
    ["scream_tv", "frankensteinfeld", 0x4aba, 0x4ddb],
    ["circuit_central", "wwwdotcomcom", 0x4ddb, 0x51ec],
    ["kung_fu_theater", "mao_tse_tongue", 0x51ec, 0x54ed],
    ["prehistory_channel", "pangaea_90210", 0x54ed, 0x57ee],
    ["toon_tv", "fine_tooning", 0x57ee, 0x5c8f],
    ["prehistory_channel", "this_old_cave", 0x5c8f, 0x5e20],
    ["circuit_central", "honey_i_shrunk_the_gecko", 0x5e20, 0x6331],
    ["scream_tv", "poltergex", 0x6331, 0x6692],
    ["kung_fu_theater", "samurai_night_fever", 0x6692, 0x6a43],
    ["rezopolis", "no_weddings_and_a_funeral", 0x6a43, 0x6c84],
    ["scream_tv", "thursday_the_12th", 0x6c84, 0x6d45],
    ["kung_fu_theater", "lizard_in_a_china_shop", 0x6d45, 0x6dc6],
    ["rezopolis", "bugged_out", 0x6dc6, 0x6df7],
    ["circuit_central", "chips_and_dips", 0x6df7, 0x6e78],
    ["prehistory_channel", "lava_dabba_doo", 0x6e78, 0x7149],
    ["scream_tv", "texas_chainsaw_manicure", 0x7149, 0x734a],
    ["rezopolis", "mazed_and_confused", 0x734a, 0x751b],
    ["channel_z", "channel_z", 0x751b, 0x75fc]
]

object_names = [
    "Object_Gex",
    "Object_CollectibleSpawn",
    "Object_unk_02",
    "Object_TVButton",
    "Object_RedRemote",
    "Object_SilverRemote",
    "Object_GoldRemote",
    "Object_EnemyDefeated",
    "Object_unk_08",
    "Object_ScreamTV_FallingPlatform",
    "Object_ScreamTV_MovingPlatform",
    "Object_ScreamTV_PushBlock",
    "Object_ScreamTV_Pumpkin",
    "Object_ScreamTV_Frankie",
    "Object_ScreamTV_HeadGhost",
    "Object_ScreamTV_HeadGhostHead",
    "Object_ScreamTV_FloatingSkull",
    "Object_ScreamTV_FloatingSkullProjectile",
    "Object_ScreamTV_Zombie",
    "Object_ScreamTV_ZombieHead",
    "Object_ScreamTV_FallingAxe",
    "Object_ScreamTV_Lantern",
    "Object_ScreamTV_Bat",
    "Object_ScreamTV_OrangeMovingPlatform",
    "Object_ScreamTV_DoorOpening",
    "Object_ScreamTV_Ghost",
    "Object_ScreamTV_ClimbWallSunEnemy",
    "Object_ScreamTV_VanishingPlatform",
    "Object_ScreamTV_MonaLisaElevator",
    "Object_ToonTV_HardHeadAreaObject",
    "Object_ToonTV_StationaryBearTrap",
    "Object_ToonTV_MovingBearTrap",
    "Object_ToonTV_Bumblebee",
    "Object_ToonTV_FallingBowlingBall",
    "Object_ToonTV_Cactus",
    "Object_ToonTV_Domino",
    "Object_ToonTV_Shark",
    "Object_ToonTV_Flower",
    "Object_ToonTV_Hunter",
    "Object_ToonTV_Mushroom",
    "Object_unk_28",
    "Object_ToonTV_Lizard",
    "Object_ToonTV_HappyFace",
    "Object_ToonTV_VanishingBlock",
    "Object_ToonTV_MovingBlock",
    "Object_ToonTV_MovingLogPlatform",
    "Object_ToonTV_StationaryLogPlatform",
    "Object_ToonTV_FlowerHammerAttack",
    "Object_ToonTV_HunterBullet",
    "Object_ToonTV_Rocket",
    "Object_PreHistory_FastDinosaur",
    "Object_PreHistory_Dragonfly",
    "Object_PreHistory_Egg",
    "Object_unk_35",
    "Object_unk_36",
    "Object_PreHistory_FallingLava",
    "Object_PreHistory_LavaRaft",
    "Object_PreHistory_MovingPlatform",
    "Object_unk_3A",
    "Object_unk_3B",
    "Object_PreHistory_Pterosaur",
    "Object_unk_3D",
    "Object_PreHistory_FallingBoulder",
    "Object_unk_3F",
    "Object_PreHistory_BeetleHorizontal",
    "Object_PreHistory_BeetleVertical",
    "Object_PreHistory_Ant",
    "Object_PreHistory_FirePlant",
    "Object_PreHistory_FirePlantProjectiles",
    "Object_PreHistory_Geyser",
    "Object_unk_46",
    "Object_PreHistory_Dinosaur",
    "Object_PreHistory_Triceratops",
    "Object_PreHistory_TriceratopsHorn",
    "Object_unk_4A",
    "Object_KungFuTheater_HangingBlade",
    "Object_KungFuTheater_Cannon",
    "Object_KungFuTheater_CannonProjectile",
    "Object_KungFuTheater_Dragonfly",
    "Object_KungFuTheater_DragonBodySegment",
    "Object_KungFuTheater_DragonHead",
    "Object_unk_51",
    "Object_KungFuTheater_DragonProjectile",
    "Object_KungFuTheater_WalkingNinja",
    "Object_KungFuTheater_JumpingNinja",
    "Object_KungFuTheater_SamuraiBody",
    "Object_KungFuTheater_SamuraiHead",
    "Object_KungFuTheater_Lizard",
    "Object_KungFuTheater_NinjaProjectile",
    "Object_KungFuTheater_SpikyLog",
    "Object_KungFuTheater_TallJar",
    "Object_KungFuTheater_Jar",
    "Object_unk_5C",
    "Object_unk_5D",
    "Object_KungFuTheater_VanishingPlatform",
    "Object_KungFuTheater_MovingPlatform",
    "Object_unk_60",
    "Object_KungFuTheater_MovingRaft",
    "Object_KungFuTheater_StationaryRaft",
    "Object_unk_63",
    "Object_unk_64",
    "Object_Rezopolis_SpecialMovingPlatform",
    "Object_Rezopolis_MovingPlatform",
    "Object_Rezopolis_RedPlatform",
    "Object_Rezopolis_ActivatedRedPlatform",
    "Object_Rezopolis_TailspinPlatform",
    "Object_Rezopolis_TailspinGear",
    "Object_unk_6B",
    "Object_unk_6C",
    "Object_unk_6D",
    "Object_Rezopolis_GreenMonster",
    "Object_unk_6F",
    "Object_unk_70",
    "Object_Rezopolis_Pincer",
    "Object_Rezopolis_Flamethrower",
    "Object_Rezopolis_UFO",
    "Object_Rezopolis_Ant",
    "Object_Rezopolis_AntSpawner",
    "Object_CircuitCentral_Ant",
    "Object_CircuitCentral_Capacitor",
    "Object_CircuitCentral_PowerUp",
    "Object_unk_79",
    "Object_CircuitCentral_LittleRobot",
    "Object_CircuitCentral_LittleRobotGear",
    "Object_CircuitCentral_ElectricBall",
    "Object_CircuitCentral_MovingPlatform",
    "Object_CircuitCentral_PoweredPlaform",
    "Object_CircuitCentral_LoweringPlatform",
    "Object_CircuitCentral_WalkerRobot",
    "Object_CircuitCentral_PoweredWalkway",
    "Object_CircuitCentral_WalkwayActivator",
    "Object_ChannelZ_ArcedGunProjectile",
    "Object_ChannelZ_ArcedGunProjectile2",
    "Object_ChannelZ_GunProjectile",
    "Object_ChannelZ_Rez",
    "Object_unk_87",
    "Object_unk_88",
    "Object_ChannelZ_RezFollowingFire",
    "Object_ChannelZ_GunProjectileExplosion",
    "Object_unk_8B",
    "Object_ChannelZ_FinalBattleButton",
    "Object_unk_8D",
    "Object_unk_8E",
    "Object_MediaDimension_MovingPlatform"
]

bank00a_data = open('./banks/bank_00a.bin', 'rb').read()

os.system('mkdir -p ./banks')
os.system('mkdir -p ./banks/maps')
os.system('mkdir -p ./banks/object_lists')
for level in levels:
    os.system('mkdir -p ./banks/maps/'+level[0])
    
    
    out = open('./banks/maps/'+level[0]+'/object_list_'+level[1]+'.asm', "w")
    
    object_data = bank00a_data[level[2]-0x4000:level[3]-0x4000]

    '''out_bin = open('./banks/object_lists/object_list_'+level[1]+'.bin', "wb")
    out_bin.write(object_data)
    out_bin.close()'''
    
    for i in range(0, len(object_data)-1, 0x10):
        objectId, xPosition, yPosition, unk05, unk06, unk07, unk08, un09, unk0a, unk0b, unk0c, unk0d, unk0e, unk0f = struct.unpack('<BHHBBBBBBBBBBB',object_data[i:i+0x10])
        
        object_name = object_names[objectId]
        object_string = "    db   {}\n    dw   ${:04x}, ${:04x}\n    db   ${:02x}, ${:02x}, ${:02x}\n    db   ${:02x}, ${:02x}, ${:02x}, ${:02x}, ${:02x}, ${:02x}, ${:02x}, ${:02x}\n\n".format(object_name, xPosition, yPosition, unk05, unk06, unk07, unk08, un09, unk0a, unk0b, unk0c, unk0d, unk0e, unk0f)
        
        out.write(object_string)
    
    out.write("    db   ObjectListTerminator\n")
    
    out.close()
    