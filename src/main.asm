; Disassembly of Gex: Deep Pocket Gecko (GBC)

INCLUDE "constants/hardware.inc"
INCLUDE "constants/constants.asm"
INCLUDE "constants/memory.asm"
INCLUDE "code/macros/macros.asm"

SECTION "bank00", ROM0[$0000]
INCLUDE "code/bank00_home.asm"
INCLUDE "code/bank00_bg_map.asm"
INCLUDE "code/bank00_cutscenes.asm"
INCLUDE "code/bank00_entity_utils.asm"
INCLUDE "code/bank00_player_sprites.asm"
INCLUDE "code/bank00_level_init.asm"
INCLUDE "code/bank00_entity_load.asm"

SECTION "bank01", ROMX[$4000], BANK[$01]
INCLUDE "code/menus/bank01_menu_load.asm"
INCLUDE "code/menus/bank01_menu_script.asm"
INCLUDE "code/menus/bank01_text_render.asm"
INCLUDE "code/menus/bank01_menu_sprites.asm"
INCLUDE "code/menus/bank01_password.asm"
INCLUDE "code/menus/bank01_menu_tables.asm"
INCLUDE "code/menus/bank01_menu_scripts.asm"
INCLUDE "code/menus/bank01_sprite_scripts.asm"
INCLUDE "code/menus/bank01_menu_gfx.asm"

SECTION "bank02", ROMX[$4000], BANK[$02]
INCLUDE "code/bank02_entity_pointer_tables.asm"
INCLUDE "code/bank02_player_actions.asm"
INCLUDE "code/bank02_update_player.asm"
INCLUDE "code/bank02_entity_actions.asm"
INCLUDE "code/bank02_update_entities.asm"
INCLUDE "code/bank02_entity_animation_data.asm"

SECTION "bank03", ROMX[$4000], BANK[$03]
data_03_4000_TileCollisionFlags:
; these flags determine which collision tiles are walls, ceilings, or kill tiles
    INCBIN "gfx/collision_tileset/bg_collision_tileset_flags.bin" 
image_003_4100_collision_tileset:
    INCBIN ".gfx/collision_tileset/image_003_4100.bin"
image_003_4400:
    INCBIN ".gfx/misc_sprites/image_003_4400.bin"
image_003_4580:
    INCBIN ".gfx/misc_sprites/image_003_4580.bin"
INCLUDE "code/bank03_bg_collision.asm"
INCLUDE "code/bank03_entity_collision.asm"
INCLUDE "code/bank03_oam_build.asm"
INCLUDE "code/bank03_map_boundaries_and_spawns.asm"
INCLUDE "code/bank03_palettes.asm"
INCLUDE "code/bank03_map_init_data.asm"
INCLUDE "code/bank03_hud_graphics.asm"
INCLUDE "code/bank03_vram_write.asm"

SECTION "bank04", ROMX[$4000], BANK[$04]
INCLUDE "code/audio/bank04_audio1.asm"

SECTION "bank05", ROMX[$4000], BANK[$05]
INCLUDE "code/audio/bank05_audio2.asm"

SECTION "bank06", ROMX[$4000], BANK[$06]
image_006_4000:
    INCBIN ".gfx/menus/image_006_4000.bin"
image_006_4000_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_006_4000_tilemap.bin"
image_006_4000_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_4000_palette_ids.bin"
image_006_47a6:
    INCBIN ".gfx/menus/image_006_47a6.bin"
image_006_47a6_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_006_47a6_tilemap.bin"
image_006_47a6_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_47a6_palette_ids.bin"
image_006_4a1e:
    INCBIN ".gfx/menus/image_006_4a1e.bin"
image_006_4a1e_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_006_4a1e_tilemap.bin"
image_006_4a1e_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_4a1e_palette_ids.bin"
image_006_59ce:
    INCBIN ".gfx/menus/image_006_59ce.bin"
image_006_59ce_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_006_59ce_tilemap.bin"
image_006_59ce_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_59ce_palette_ids.bin"
image_006_6086:
    INCBIN ".gfx/menus/image_006_6086.bin"
image_006_6086_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_006_6086_tilemap.bin"
image_006_6086_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_6086_palette_ids.bin"
image_006_67c6:
    INCBIN ".gfx/menus/image_006_67c6.bin"
image_006_67c6_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_006_67c6_tilemap.bin"
image_006_67c6_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_67c6_palette_ids.bin"

SECTION "bank07", ROMX[$4000], BANK[$07]
    ; $4000  60x6 tiles - ENTITY_SUPERHERO_SHOW_MAD_BOMBER
image_superhero_show_mad_bomber_007_4000:
    INCBIN ".gfx/entity_sprites/image_superhero_show_mad_bomber_007_4000.bin"
    ; $5680  9x4 tiles - not reachable from any action
image_unused_007_5680:
    INCBIN ".gfx/entity_sprites/image_unused_007_5680.bin"
    ; $58c0  6x6 tiles - ENTITY_SUPERHERO_SHOW_MAD_BOMBER
image_superhero_show_mad_bomber_007_58c0:
    INCBIN ".gfx/entity_sprites/image_superhero_show_mad_bomber_007_58c0.bin"

image_007_5b00:
    INCBIN ".gfx/menus/image_007_5b00.bin"
image_007_5b00_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_007_5b00_tilemap.bin"

SECTION "bank08", ROMX[$4000], BANK[$08]
    ; $4000  116x6 tiles - ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
image_anime_channel_big_silver_robot_008_4000:
    INCBIN ".gfx/entity_sprites/image_anime_channel_big_silver_robot_008_4000.bin"

SECTION "bank09", ROMX[$4000], BANK[$09]
    ; $4000  152x6 tiles - ENTITY_HOLIDAY_TV_EVIL_SANTA
image_holiday_tv_evil_santa_009_4000:
    INCBIN ".gfx/entity_sprites/image_holiday_tv_evil_santa_009_4000.bin"
    ; $7900  12x8 tiles - ENTITY_TUT_TV_COFFIN
image_tut_tv_coffin_009_7900:
    INCBIN ".gfx/entity_sprites/image_tut_tv_coffin_009_7900.bin"

SECTION "bank0a", ROMX[$4000], BANK[$0A]
    ; $4000  1x2 tiles - ENTITY_FLY_1, ENTITY_FLY_2, ENTITY_FLY_3, ENTITY_FLY_4, ENTITY_FLY_5
image_fly_1_fly_2_and_3_more_00a_4000:
    INCBIN ".gfx/entity_sprites/image_fly_1_fly_2_and_3_more_00a_4000.bin"
    ; $4020  1x2 tiles - ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
image_mystery_tv_safari_sam_projectile_00a_4020:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_safari_sam_projectile_00a_4020.bin"
    ; $4040  7x2 tiles - ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE, ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE
image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040:
    INCBIN ".gfx/entity_sprites/image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040.bin"
    ; $4120  1x2 tiles - ENTITY_GOAL_COUNTER_1
image_goal_counter_1_00a_4120:
    INCBIN ".gfx/entity_sprites/image_goal_counter_1_00a_4120.bin"
    ; $4140  1x2 tiles - ENTITY_GOAL_COUNTER_2
image_goal_counter_2_00a_4140:
    INCBIN ".gfx/entity_sprites/image_goal_counter_2_00a_4140.bin"
    ; $4160  1x2 tiles - ENTITY_GOAL_COUNTER_3
image_goal_counter_3_00a_4160:
    INCBIN ".gfx/entity_sprites/image_goal_counter_3_00a_4160.bin"
    ; $4180  1x2 tiles - ENTITY_GOAL_COUNTER_4
image_goal_counter_4_00a_4180:
    INCBIN ".gfx/entity_sprites/image_goal_counter_4_00a_4180.bin"
    ; $41a0  1x2 tiles - ENTITY_GOAL_COUNTER_5
image_goal_counter_5_00a_41a0:
    INCBIN ".gfx/entity_sprites/image_goal_counter_5_00a_41a0.bin"
    ; $41c0  1x2 tiles - ENTITY_GOAL_COUNTER_6
image_goal_counter_6_00a_41c0:
    INCBIN ".gfx/entity_sprites/image_goal_counter_6_00a_41c0.bin"
    ; $41e0  1x2 tiles - ENTITY_GOAL_COUNTER_7
image_goal_counter_7_00a_41e0:
    INCBIN ".gfx/entity_sprites/image_goal_counter_7_00a_41e0.bin"
    ; $4200  1x2 tiles - not reachable from any action
image_unused_00a_4200:
    INCBIN ".gfx/entity_sprites/image_unused_00a_4200.bin"
    ; $4220  1x2 tiles - ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE, ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
image_tut_tv_snake_right_projectile_and_1_more_00a_4220:
    INCBIN ".gfx/entity_sprites/image_tut_tv_snake_right_projectile_and_1_more_00a_4220.bin"
    ; $4240  1x2 tiles - not reachable from any action
image_unused_00a_4240:
    INCBIN ".gfx/entity_sprites/image_unused_00a_4240.bin"
    ; $4260  4x2 tiles - ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER, ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER
image_anime_channel_blue_beam_barrier_and_1_more_00a_4260:
    INCBIN ".gfx/entity_sprites/image_anime_channel_blue_beam_barrier_and_1_more_00a_4260.bin"
    ; $42e0  2x2 tiles - ENTITY_ANIME_CHANNEL_ON_SWITCH2, ENTITY_ANIME_CHANNEL_ON_SWITCH, ENTITY_ANIME_CHANNEL_OFF_SWITCH
image_anime_channel_on_switch2_and_2_more_00a_42e0:
    INCBIN ".gfx/entity_sprites/image_anime_channel_on_switch2_and_2_more_00a_42e0.bin"
    ; $4320  1x2 tiles - ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE
image_anime_channel_secbot_projectile_00a_4320:
    INCBIN ".gfx/entity_sprites/image_anime_channel_secbot_projectile_00a_4320.bin"
    ; $4340  3x2 tiles - not reachable from any action
image_unused_00a_4340:
    INCBIN ".gfx/entity_sprites/image_unused_00a_4340.bin"
    ; $43a0  10x2 tiles - ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE
image_superhero_show_convict_projectile_00a_43a0:
    INCBIN ".gfx/entity_sprites/image_superhero_show_convict_projectile_00a_43a0.bin"
    ; $44e0  1x2 tiles - ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
image_lizard_of_oz_cannon_projectile_00a_44e0:
    INCBIN ".gfx/entity_sprites/image_lizard_of_oz_cannon_projectile_00a_44e0.bin"
    ; $4500  12x2 tiles - ENTITY_ANIME_CHANNEL_FAN_LIFT
image_anime_channel_fan_lift_00a_4500:
    INCBIN ".gfx/entity_sprites/image_anime_channel_fan_lift_00a_4500.bin"
    ; $4680  6x2 tiles - ENTITY_CHANNEL_Z_METEOR
image_channel_z_meteor_00a_4680:
    INCBIN ".gfx/entity_sprites/image_channel_z_meteor_00a_4680.bin"
    ; $4740  1x4 tiles - not reachable from any action
image_unused_00a_4740:
    INCBIN ".gfx/entity_sprites/image_unused_00a_4740.bin"
    ; $4780  1x2 tiles - ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
image_mystery_tv_ghost_knight_projectile_00a_4780:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_ghost_knight_projectile_00a_4780.bin"
    ; $47a0  1x2 tiles - ENTITY_CHANNEL_Z_METEOR
image_channel_z_meteor_00a_47a0:
    INCBIN ".gfx/entity_sprites/image_channel_z_meteor_00a_47a0.bin"
    ; $47c0  4x2 tiles - ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
image_marsupial_madness_bird_projectile_00a_47c0:
    INCBIN ".gfx/entity_sprites/image_marsupial_madness_bird_projectile_00a_47c0.bin"
    ; $4840  3x2 tiles - not reachable from any action
image_unused_00a_4840:
    INCBIN ".gfx/entity_sprites/image_unused_00a_4840.bin"
    ; $48a0  16x2 tiles - ENTITY_ANIME_CHANNEL_GRENADE
image_anime_channel_grenade_00a_48a0:
    INCBIN ".gfx/entity_sprites/image_anime_channel_grenade_00a_48a0.bin"
    ; $4aa0  1x2 tiles - ENTITY_BONUS_COIN, ENTITY_UNK0E, ENTITY_UNK0F, ENTITY_UNK10
image_bonus_coin_unk0e_and_2_more_00a_4aa0:
    INCBIN ".gfx/entity_sprites/image_bonus_coin_unk0e_and_2_more_00a_4aa0.bin"
    ; $4ac0  7x2 tiles - ENTITY_BONUS_COIN
image_bonus_coin_00a_4ac0:
    INCBIN ".gfx/entity_sprites/image_bonus_coin_00a_4ac0.bin"
    ; $4ba0  12x2 tiles - ENTITY_FLY_COIN_SPAWN
image_fly_coin_spawn_00a_4ba0:
    INCBIN ".gfx/entity_sprites/image_fly_coin_spawn_00a_4ba0.bin"
    ; $4d20  16x2 tiles - ENTITY_PAW_COIN
image_paw_coin_00a_4d20:
    INCBIN ".gfx/entity_sprites/image_paw_coin_00a_4d20.bin"
    ; $4f20  2x2 tiles - ENTITY_TV_BUTTON
image_tv_button_00a_4f20:
    INCBIN ".gfx/entity_sprites/image_tv_button_00a_4f20.bin"
    ; $4f60  1x4 tiles - not reachable from any action
image_unused_00a_4f60:
    INCBIN ".gfx/entity_sprites/image_unused_00a_4f60.bin"
    ; $4fa0  16x2 tiles - ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
image_holiday_tv_evil_santa_projectile_00a_4fa0:
    INCBIN ".gfx/entity_sprites/image_holiday_tv_evil_santa_projectile_00a_4fa0.bin"
    ; $51a0  8x2 tiles - ENTITY_MYSTERY_TV_FISH
image_mystery_tv_fish_00a_51a0:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_fish_00a_51a0.bin"
    ; $52a0  12x2 tiles - ENTITY_TUT_TV_HAND
image_tut_tv_hand_00a_52a0:
    INCBIN ".gfx/entity_sprites/image_tut_tv_hand_00a_52a0.bin"
    ; $5420  1x4 tiles - not reachable from any action
image_unused_00a_5420:
    INCBIN ".gfx/entity_sprites/image_unused_00a_5420.bin"
    ; $5460  10x2 tiles - ENTITY_TUT_TV_HAND
image_tut_tv_hand_00a_5460:
    INCBIN ".gfx/entity_sprites/image_tut_tv_hand_00a_5460.bin"
    ; $55a0  10x2 tiles - ENTITY_HOLIDAY_TV_PENGUIN
image_holiday_tv_penguin_00a_55a0:
    INCBIN ".gfx/entity_sprites/image_holiday_tv_penguin_00a_55a0.bin"
    ; $56e0  1x4 tiles - not reachable from any action
image_unused_00a_56e0:
    INCBIN ".gfx/entity_sprites/image_unused_00a_56e0.bin"
    ; $5720  4x2 tiles - ENTITY_HOLIDAY_TV_PENGUIN
image_holiday_tv_penguin_00a_5720:
    INCBIN ".gfx/entity_sprites/image_holiday_tv_penguin_00a_5720.bin"
    ; $57a0  8x4 tiles - not reachable from any action
image_unused_00a_57a0:
    INCBIN ".gfx/entity_sprites/image_unused_00a_57a0.bin"
    ; $59a0  2x2 tiles - ENTITY_ANIME_CHANNEL_RISING_PLATFORM
image_anime_channel_rising_platform_00a_59a0:
    INCBIN ".gfx/entity_sprites/image_anime_channel_rising_platform_00a_59a0.bin"
    ; $59e0  6x2 tiles - ENTITY_SUPERHERO_SHOW_BOMB
image_superhero_show_bomb_00a_59e0:
    INCBIN ".gfx/entity_sprites/image_superhero_show_bomb_00a_59e0.bin"
    ; $5aa0  6x2 tiles - ENTITY_SUPERHERO_SHOW_SPIDER
image_superhero_show_spider_00a_5aa0:
    INCBIN ".gfx/entity_sprites/image_superhero_show_spider_00a_5aa0.bin"
    ; $5b60  10x2 tiles - ENTITY_SUPERHERO_SHOW_STRAY_CAT
image_superhero_show_stray_cat_00a_5b60:
    INCBIN ".gfx/entity_sprites/image_superhero_show_stray_cat_00a_5b60.bin"
    ; $5ca0  1x4 tiles - not reachable from any action
image_unused_00a_5ca0:
    INCBIN ".gfx/entity_sprites/image_unused_00a_5ca0.bin"
    ; $5ce0  4x2 tiles - ENTITY_SUPERHERO_SHOW_STRAY_CAT
image_superhero_show_stray_cat_00a_5ce0:
    INCBIN ".gfx/entity_sprites/image_superhero_show_stray_cat_00a_5ce0.bin"
    ; $5d60  6x2 tiles - ENTITY_SUPERHERO_SHOW_RAT
image_superhero_show_rat_00a_5d60:
    INCBIN ".gfx/entity_sprites/image_superhero_show_rat_00a_5d60.bin"
    ; $5e20  10x2 tiles - ENTITY_SUPERHERO_SHOW_CHOMPER_TV
image_superhero_show_chomper_tv_00a_5e20:
    INCBIN ".gfx/entity_sprites/image_superhero_show_chomper_tv_00a_5e20.bin"
    ; $5f60  6x2 tiles - ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR
image_superhero_show_crumbling_floor_00a_5f60:
    INCBIN ".gfx/entity_sprites/image_superhero_show_crumbling_floor_00a_5f60.bin"
    ; $6020  12x2 tiles - ENTITY_SUPERHERO_SHOW_BOMB
image_superhero_show_bomb_00a_6020:
    INCBIN ".gfx/entity_sprites/image_superhero_show_bomb_00a_6020.bin"
    ; $61a0  24x2 tiles - ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT
image_anime_channel_small_blue_robot_00a_61a0:
    INCBIN ".gfx/entity_sprites/image_anime_channel_small_blue_robot_00a_61a0.bin"
    ; $64a0  12x2 tiles - ENTITY_ANIME_CHANNEL_SECBOT
image_anime_channel_secbot_00a_64a0:
    INCBIN ".gfx/entity_sprites/image_anime_channel_secbot_00a_64a0.bin"
    ; $6620  2x4 tiles - not reachable from any action
image_unused_00a_6620:
    INCBIN ".gfx/entity_sprites/image_unused_00a_6620.bin"
    ; $66a0  10x2 tiles - ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
image_lizard_of_oz_brain_of_oz_projectile_00a_66a0:
    INCBIN ".gfx/entity_sprites/image_lizard_of_oz_brain_of_oz_projectile_00a_66a0.bin"
    ; $67e0  1x4 tiles - not reachable from any action
image_unused_00a_67e0:
    INCBIN ".gfx/entity_sprites/image_unused_00a_67e0.bin"
    ; $6820  8x2 tiles - ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2
image_lizard_of_oz_cannon_projectile_2_00a_6820:
    INCBIN ".gfx/entity_sprites/image_lizard_of_oz_cannon_projectile_2_00a_6820.bin"
    ; $6920  2x2 tiles - ENTITY_CHANNEL_Z_GREEN_BLOCK
image_channel_z_green_block_00a_6920:
    INCBIN ".gfx/entity_sprites/image_channel_z_green_block_00a_6920.bin"
    ; $6960  3x4 tiles - not reachable from any action
image_unused_00a_6960:
    INCBIN ".gfx/entity_sprites/image_unused_00a_6960.bin"
    ; $6a20  2x2 tiles - ENTITY_CHANNEL_Z_ORANGE_BLOCK
image_channel_z_orange_block_00a_6a20:
    INCBIN ".gfx/entity_sprites/image_channel_z_orange_block_00a_6a20.bin"
    ; $6a60  3x4 tiles - not reachable from any action
image_unused_00a_6a60:
    INCBIN ".gfx/entity_sprites/image_unused_00a_6a60.bin"
    ; $6b20  12x2 tiles - ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY, ENTITY_CHANNEL_Z_REZ_PROJECTILE
image_anime_channel_fire_wall_enemy_and_1_more_00a_6b20:
    INCBIN ".gfx/entity_sprites/image_anime_channel_fire_wall_enemy_and_1_more_00a_6b20.bin"
    ; $6ca0  16x2 tiles - ENTITY_WESTERN_STATION_HARD_HAT
image_western_station_hard_hat_00a_6ca0:
    INCBIN ".gfx/entity_sprites/image_western_station_hard_hat_00a_6ca0.bin"
    ; $6ea0  19x4 tiles - not reachable from any action
image_unused_00a_6ea0:
    INCBIN ".gfx/entity_sprites/image_unused_00a_6ea0.bin"
    ; $7360  2x2 tiles - ENTITY_WESTERN_STATION_HARD_HAT
image_western_station_hard_hat_00a_7360:
    INCBIN ".gfx/entity_sprites/image_western_station_hard_hat_00a_7360.bin"
    ; $73a0  12x2 tiles - ENTITY_WESTERN_STATION_BAT
image_western_station_bat_00a_73a0:
    INCBIN ".gfx/entity_sprites/image_western_station_bat_00a_73a0.bin"
    ; $7520  18x2 tiles - ENTITY_MARSUPIAL_MADNESS_BIRD
image_marsupial_madness_bird_00a_7520:
    INCBIN ".gfx/entity_sprites/image_marsupial_madness_bird_00a_7520.bin"
    ; $7760  20x2 tiles - ENTITY_WESTERN_STATION_PLAYING_CARD
image_western_station_playing_card_00a_7760:
    INCBIN ".gfx/entity_sprites/image_western_station_playing_card_00a_7760.bin"
    ; $79e0  3x2 tiles - ENTITY_TUT_TV_RISING_PLATFORM, ENTITY_TUT_TV_SIDEWAYS_PLATFORM
image_tut_tv_rising_platform_tut_tv_sideways_platform_00a_79e0:
    INCBIN ".gfx/entity_sprites/image_tut_tv_rising_platform_tut_tv_sideways_platform_00a_79e0.bin"
    ; $7a40  3x2 tiles - ENTITY_WESTERN_STATION_RISING_PLATFORM
image_western_station_rising_platform_00a_7a40:
    INCBIN ".gfx/entity_sprites/image_western_station_rising_platform_00a_7a40.bin"

SECTION "bank0b", ROMX[$4000], BANK[$0B]
    ; $4000  4x4 tiles - ENTITY_TUT_TV_LOST_ARK
image_tut_tv_lost_ark_00b_4000:
    INCBIN ".gfx/entity_sprites/image_tut_tv_lost_ark_00b_4000.bin"
    ; $4100  8x4 tiles - not reachable from any action
image_unused_00b_4100:
    INCBIN ".gfx/entity_sprites/image_unused_00b_4100.bin"
    ; $4300  44x4 tiles - ENTITY_TUT_TV_LOST_ARK
image_tut_tv_lost_ark_00b_4300:
    INCBIN ".gfx/entity_sprites/image_tut_tv_lost_ark_00b_4300.bin"
    ; $4e00  16x4 tiles - ENTITY_ANIME_CHANNEL_DOOR, ENTITY_ANIME_CHANNEL_DOOR2
image_anime_channel_door_anime_channel_door2_00b_4e00:
    INCBIN ".gfx/entity_sprites/image_anime_channel_door_anime_channel_door2_00b_4e00.bin"
    ; $5200  12x8 tiles - ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
image_anime_channel_alien_culture_tube_00b_5200:
    INCBIN ".gfx/entity_sprites/image_anime_channel_alien_culture_tube_00b_5200.bin"
    ; $5800  4x4 tiles - ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK
image_superhero_show_water_tower_tank_00b_5800:
    INCBIN ".gfx/entity_sprites/image_superhero_show_water_tower_tank_00b_5800.bin"
    ; $5900  12x4 tiles - ENTITY_MARSUPIAL_MADNESS_BELL
image_marsupial_madness_bell_00b_5900:
    INCBIN ".gfx/entity_sprites/image_marsupial_madness_bell_00b_5900.bin"
    ; $5c00  44x4 tiles - ENTITY_SUPERHERO_SHOW_YELLOW_GOON
image_superhero_show_yellow_goon_00b_5c00:
    INCBIN ".gfx/entity_sprites/image_superhero_show_yellow_goon_00b_5c00.bin"
    ; $6700  60x4 tiles - ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL
image_anime_channel_sailor_toon_girl_00b_6700:
    INCBIN ".gfx/entity_sprites/image_anime_channel_sailor_toon_girl_00b_6700.bin"
    ; $7600  32x4 tiles - ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN
image_gextreme_sports_bonus_time_coin_00b_7600:
    INCBIN ".gfx/entity_sprites/image_gextreme_sports_bonus_time_coin_00b_7600.bin"
    ; $7e00  4x4 tiles - ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT, ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT
image_anime_channel_mech_facing_right_and_1_more_00b_7e00:
    INCBIN ".gfx/entity_sprites/image_anime_channel_mech_facing_right_and_1_more_00b_7e00.bin"

SECTION "bank0c", ROMX[$4000], BANK[$0C]
    ; $4000  72x4 tiles - ENTITY_MYSTERY_TV_REZLING
image_mystery_tv_rezling_00c_4000:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_rezling_00c_4000.bin"
    ; $5200  68x4 tiles - ENTITY_MYSTERY_TV_SAFARI_SAM
image_mystery_tv_safari_sam_00c_5200:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_safari_sam_00c_5200.bin"
    ; $6300  48x4 tiles - ENTITY_SLOT_STRIDE, ENTITY_GEXTREME_SPORTS_ELF
image_slot_stride_gextreme_sports_elf_00c_6300:
    INCBIN ".gfx/entity_sprites/image_slot_stride_gextreme_sports_elf_00c_6300.bin"
    ; $6f00  36x4 tiles - ENTITY_TUT_TV_SNAKE_FACING_RIGHT, ENTITY_TUT_TV_SNAKE_FACING_LEFT
image_tut_tv_snake_facing_right_and_1_more_00c_6f00:
    INCBIN ".gfx/entity_sprites/image_tut_tv_snake_facing_right_and_1_more_00c_6f00.bin"
    ; $7800  15x4 tiles - loaded by HDMA, not by any entity
image_hud_tiles_00c_7800:
    INCBIN ".gfx/entity_sprites/image_hud_tiles_00c_7800.bin"
    ; $7bc0  1x4 tiles - loaded by HDMA, not by any entity
image_hud_tilemap_00c_7bc0:
    INCBIN "gfx/entity_sprites/image_hud_tilemap_00c_7bc0.bin"
    ; $7c00  1x4 tiles - loaded by HDMA, not by any entity
image_hud_attributes_00c_7c00:
    INCBIN "gfx/entity_sprites/image_hud_attributes_00c_7c00.bin"

SECTION "bank0d", ROMX[$4000], BANK[$0D]
    ; $4000  27x4 tiles - ENTITY_GREEN_FLY_TV, ENTITY_PURPLE_FLY_TV, ENTITY_UNK_FLY_TV_3, ENTITY_BLUE_FLY_TV, ENTITY_UNK_FLY_TV_5
image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000:
    INCBIN ".gfx/entity_sprites/image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000.bin"
    ; $46c0  15x4 tiles - ENTITY_MYSTERY_TV_BLOOD_COOLER
image_mystery_tv_blood_cooler_00d_46c0:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_blood_cooler_00d_46c0.bin"
    ; $4a80  9x4 tiles - ENTITY_MYSTERY_TV_GHOST_KNIGHT
image_mystery_tv_ghost_knight_00d_4a80:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_ghost_knight_00d_4a80.bin"
    ; $4cc0  12x4 tiles - not reachable from any action
image_unused_00d_4cc0:
    INCBIN ".gfx/entity_sprites/image_unused_00d_4cc0.bin"
    ; $4fc0  9x4 tiles - ENTITY_MYSTERY_TV_GHOST_KNIGHT
image_mystery_tv_ghost_knight_00d_4fc0:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_ghost_knight_00d_4fc0.bin"
    ; $5200  24x4 tiles - ENTITY_TV_REMOTE, ENTITY_FREESTANDING_REMOTE
image_tv_remote_freestanding_remote_00d_5200:
    INCBIN ".gfx/entity_sprites/image_tv_remote_freestanding_remote_00d_5200.bin"
    ; $5800  24x4 tiles - ENTITY_TV_REMOTE
image_tv_remote_00d_5800:
    INCBIN ".gfx/entity_sprites/image_tv_remote_00d_5800.bin"
    ; $5e00  9x4 tiles - ENTITY_HOLIDAY_TV_ICE_SCULPTURE
image_holiday_tv_ice_sculpture_00d_5e00:
    INCBIN ".gfx/entity_sprites/image_holiday_tv_ice_sculpture_00d_5e00.bin"
    ; $6040  15x4 tiles - ENTITY_TUT_TV_BEE
image_tut_tv_bee_00d_6040:
    INCBIN ".gfx/entity_sprites/image_tut_tv_bee_00d_6040.bin"
    ; $6400  2x6 tiles - ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
image_superhero_show_water_tower_stand_00d_6400:
    INCBIN ".gfx/entity_sprites/image_superhero_show_water_tower_stand_00d_6400.bin"
    ; $64c0  24x4 tiles - ENTITY_SUPERHERO_SHOW_CONVICT
image_superhero_show_convict_00d_64c0:
    INCBIN ".gfx/entity_sprites/image_superhero_show_convict_00d_64c0.bin"
    ; $6ac0  21x4 tiles - ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
image_lizard_of_oz_brain_of_oz_00d_6ac0:
    INCBIN ".gfx/entity_sprites/image_lizard_of_oz_brain_of_oz_00d_6ac0.bin"
    ; $7000  3x4 tiles - ENTITY_TV_REMOTE
image_tv_remote_00d_7000:
    INCBIN ".gfx/entity_sprites/image_tv_remote_00d_7000.bin"
    ; $70c0  59x2 tiles - not reachable from any action
image_unused_00d_70c0:
    INCBIN ".gfx/entity_sprites/image_unused_00d_70c0.bin"

SECTION "bank0e", ROMX[$4000], BANK[$0E]
    ; $4000  56x4 tiles - ENTITY_LIZARD_OF_OZ_CANNON
image_lizard_of_oz_cannon_00e_4000:
    INCBIN ".gfx/entity_sprites/image_lizard_of_oz_cannon_00e_4000.bin"
    ; $4e00  12x4 tiles - ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON
image_anime_channel_planet_o_blast_weapon_00e_4e00:
    INCBIN ".gfx/entity_sprites/image_anime_channel_planet_o_blast_weapon_00e_4e00.bin"

SECTION "bank0f", ROMX[$4000], BANK[$0F]
    ; $4000  18x4 tiles - ENTITY_MYSTERY_TV_MAGIC_SWORD
image_mystery_tv_magic_sword_00f_4000:
    INCBIN ".gfx/entity_sprites/image_mystery_tv_magic_sword_00f_4000.bin"
    ; $4480  4x2 tiles - ENTITY_TUT_TV_RAFT
image_tut_tv_raft_00f_4480:
    INCBIN ".gfx/entity_sprites/image_tut_tv_raft_00f_4480.bin"
    ; $4500  16x4 tiles - ENTITY_TUT_TV_RA_STAFF
image_tut_tv_ra_staff_00f_4500:
    INCBIN ".gfx/entity_sprites/image_tut_tv_ra_staff_00f_4500.bin"
    ; $4900  12x2 tiles - ENTITY_TUT_TV_BREAKABLE_BLOCK
image_tut_tv_breakable_block_00f_4900:
    INCBIN ".gfx/entity_sprites/image_tut_tv_breakable_block_00f_4900.bin"
    ; $4a80  4x2 tiles - ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR, ENTITY_ANIME_CHANNEL_ELEVATOR
image_anime_channel_disappearing_floor_and_1_more_00f_4a80:
    INCBIN ".gfx/entity_sprites/image_anime_channel_disappearing_floor_and_1_more_00f_4a80.bin"
    ; $4b00  16x4 tiles - ENTITY_WESTERN_STATION_ROCK_PLATFORM
image_western_station_rock_platform_00f_4b00:
    INCBIN ".gfx/entity_sprites/image_western_station_rock_platform_00f_4b00.bin"

SECTION "bank10", ROMX[$4000], BANK[$10]
    ; $4000  120x8 tiles - ENTITY_WW_GEX_WRESTLING_ROCK_HARD
image_ww_gex_wrestling_rock_hard_010_4000:
    INCBIN ".gfx/entity_sprites/image_ww_gex_wrestling_rock_hard_010_4000.bin"

SECTION "bank11", ROMX[$4000], BANK[$11]
image_11_4000:
    INCBIN ".gfx/menus/image_011_4000.bin"
image_11_4000_tilemap:
    INCBIN "gfx/menus/menu_tilemaps/image_011_4000_tilemap.bin"
image_11_4000_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_011_4000_palette_ids.bin"

SECTION "bank12", ROMX[$4000], BANK[$12]
SECTION "bank13", ROMX[$4000], BANK[$13]
SECTION "bank14", ROMX[$4000], BANK[$14]
SECTION "bank15", ROMX[$4000], BANK[$15]
SECTION "bank16", ROMX[$4000], BANK[$16]
SECTION "bank17", ROMX[$4000], BANK[$17]
SECTION "bank18", ROMX[$4000], BANK[$18]
SECTION "bank19", ROMX[$4000], BANK[$19]
SECTION "bank1A", ROMX[$4000], BANK[$1A]
SECTION "bank1B", ROMX[$4000], BANK[$1B]

SECTION "bank1C", ROMX[$4000], BANK[$1C]
bank1c_text:
    INCLUDE "code/menus/bank1c_text.asm"

SECTION "bank1d", ROMX[$4000], BANK[$1D]
    ; $4000  56x6 tiles - ENTITY_WESTERN_STATION_ENEMY_CACTUS
image_western_station_enemy_cactus_01d_4000:
    INCBIN ".gfx/entity_sprites/image_western_station_enemy_cactus_01d_4000.bin"
    ; $5500  4x6 tiles - ENTITY_WESTERN_STATION_ENEMY_CACTUS, ENTITY_WESTERN_STATION_CACTUS
image_western_station_enemy_cactus_and_1_more_01d_5500:
    INCBIN ".gfx/entity_sprites/image_western_station_enemy_cactus_and_1_more_01d_5500.bin"

SECTION "bank1e", ROMX[$4000], BANK[$1E]
    ; $4000  42x8 tiles - ENTITY_CHANNEL_Z_REZ
image_channel_z_rez_01e_4000:
    INCBIN ".gfx/entity_sprites/image_channel_z_rez_01e_4000.bin"
    ; $5500  14x4 tiles - not reachable from any action
image_unused_01e_5500:
    INCBIN ".gfx/entity_sprites/image_unused_01e_5500.bin"
    ; $5880  28x8 tiles - ENTITY_CHANNEL_Z_REZ
image_channel_z_rez_01e_5880:
    INCBIN ".gfx/entity_sprites/image_channel_z_rez_01e_5880.bin"

SECTION "bank1f", ROMX[$4000], BANK[$1F]
image_01f_00:
    INCBIN ".gfx/secondary_tilesets/image_01f_00.bin"
image_01f_00_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_00_palette_ids.bin"
image_01f_00_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_00_palette.bin"
image_01f_01:
    INCBIN ".gfx/secondary_tilesets/image_01f_01.bin"
image_01f_01_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_01_palette_ids.bin"
image_01f_01_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_01_palette.bin"
image_01f_02:
    INCBIN ".gfx/secondary_tilesets/image_01f_02.bin"
image_01f_02_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_02_palette_ids.bin"
image_01f_02_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_02_palette.bin"
image_01f_03:
    INCBIN ".gfx/secondary_tilesets/image_01f_03.bin"
image_01f_03_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_03_palette_ids.bin"
image_01f_03_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_03_palette.bin"
image_01f_04:
    INCBIN ".gfx/secondary_tilesets/image_01f_04.bin"
image_01f_04_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_04_palette_ids.bin"
image_01f_04_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_04_palette.bin"
image_01f_05:
    INCBIN ".gfx/secondary_tilesets/image_01f_05.bin"
image_01f_05_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_05_palette_ids.bin"
image_01f_05_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_05_palette.bin"
image_01f_06:
    INCBIN ".gfx/secondary_tilesets/image_01f_06.bin"
image_01f_06_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_06_palette_ids.bin"
image_01f_06_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_06_palette.bin"
image_01f_07:
    INCBIN ".gfx/secondary_tilesets/image_01f_07.bin"
image_01f_07_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_07_palette_ids.bin"
image_01f_07_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_07_palette.bin"
image_01f_08:
    INCBIN ".gfx/secondary_tilesets/image_01f_08.bin"
image_01f_08_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_08_palette_ids.bin"
image_01f_08_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_08_palette.bin"
image_01f_09:
    INCBIN ".gfx/secondary_tilesets/image_01f_09.bin"
image_01f_09_palette_ids:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_09_palette_ids.bin"
image_01f_09_palette:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_09_palette.bin"

SECTION "bank20", ROMX[$4000], BANK[$20]

SECTION "bank21", ROMX[$4000], BANK[$21]
GexCave_1_palette:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_palette.bin"
GexCave_2_palette:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_palette.bin"
GexCave_3_palette:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_palette.bin"
GexCave_4_palette:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_palette.bin"
HolidayTV_1_palette:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_palette.bin"
HolidayTV_2_palette:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_palette.bin"
HolidayTV_3_palette_4180:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_3_palette_4180.bin"
HolidayTV_4_palette:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_palette.bin"
MysteryTV_1_palette:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_palette.bin"
MysteryTV_2_palette:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_palette.bin"
MysteryTV_3_palette:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_palette.bin"
MysteryTV_4_palette:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_palette.bin"
MysteryTV_5_palette_4300:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_5_palette_4300.bin"
MysteryTV_6_palette_4340:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_6_palette_4340.bin"
MysteryTV_7_palette:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_palette.bin"
MysteryTV_8_palette:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_palette.bin"
TutTV_1_palette:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_palette.bin"
TutTV_2_palette:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_palette.bin"
TutTV_3_palette:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_palette.bin"
TutTV_4_palette:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_palette.bin"
TutTV_5_palette:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_palette.bin"
TutTV_6_palette:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_palette.bin"
TutTV_7_palette:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_palette.bin"
WesternStation_1_palette:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_palette.bin"
WesternStation_2_palette:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_palette.bin"
WesternStation_3_palette:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_palette.bin"
WesternStation_4_palette:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_palette.bin"
WesternStation_5_palette:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_palette.bin"
WesternStation_6_palette:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_palette.bin"
AnimeChannel_1_palette:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_palette.bin"
AnimeChannel_2_palette:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_palette.bin"
AnimeChannel_3_palette:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_palette.bin"
AnimeChannel_4_palette:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_palette.bin"
AnimeChannel_5_palette:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_palette.bin"
AnimeChannel_6_palette:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_palette.bin"
SuperheroShow_1_palette:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_palette.bin"
SuperheroShow_2_palette:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_palette.bin"
SuperheroShow_3_palette:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_palette.bin"
SuperheroShow_4_palette:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_palette.bin"
SuperheroShow_5_palette:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_palette.bin"
SuperheroShow_6_palette:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_palette.bin"
GextremeSports_1_palette:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_palette.bin"
MarsupialMadness_1_palette:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_palette.bin"
WWGexWrestling_1_palette:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_palette.bin"
LizardOfOz_1_palette:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_palette.bin"
ChannelZ_1_palette:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_palette.bin"
ChannelZ_2_palette:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_palette.bin"
ChannelZ_3_palette:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_palette.bin"
ChannelZ_4_palette:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_palette.bin"
ChannelZ_5_palette:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_palette.bin"
GexCave_collectible_list:
    INCBIN "data/maps/GexCave/GexCave_collectible_list.bin"
HolidayTV_collectible_list:
    INCBIN "data/maps/HolidayTV/HolidayTV_collectible_list.bin"
MysteryTV_collectible_list:
    INCBIN "data/maps/MysteryTV/MysteryTV_collectible_list.bin"
TutTV_collectible_list:
    INCBIN "data/maps/TutTV/TutTV_collectible_list.bin"
WesternStation_collectible_list:
    INCBIN "data/maps/WesternStation/WesternStation_collectible_list.bin"
AnimeChannel_collectible_list:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_collectible_list.bin"
SuperheroShow_collectible_list:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_collectible_list.bin"
GextremeSports_collectible_list:
    INCBIN "data/maps/GextremeSports/GextremeSports_collectible_list.bin"
MarsupialMadness_collectible_list:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_collectible_list.bin"
WWGexWrestling_collectible_list:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_collectible_list.bin"
LizardOfOz_collectible_list:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_collectible_list.bin"
ChannelZ_collectible_list:
    INCBIN "data/maps/ChannelZ/ChannelZ_collectible_list.bin"

SECTION "bank22", ROMX[$4000], BANK[$22]
GexCave_entity_list:
    INCBIN "data/maps/GexCave/GexCave_entity_list.bin"
HolidayTV_entity_list:
    INCBIN "data/maps/HolidayTV/HolidayTV_entity_list.bin"
MysteryTV_entity_list:
    INCBIN "data/maps/MysteryTV/MysteryTV_entity_list.bin"
TutTV_entity_list:
    INCBIN "data/maps/TutTV/TutTV_entity_list.bin"
WesternStation_entity_list:
    INCBIN "data/maps/WesternStation/WesternStation_entity_list.bin"
AnimeChannel_entity_list:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_entity_list.bin"
SuperheroShow_entity_list:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_entity_list.bin"
GextremeSports_entity_list:
    INCBIN "data/maps/GextremeSports/GextremeSports_entity_list.bin"
MarsupialMadness_entity_list:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_entity_list.bin"
WWGexWrestling_entity_list:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_entity_list.bin"
LizardOfOz_entity_list:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_entity_list.bin"
ChannelZ_entity_list:
    INCBIN "data/maps/ChannelZ/ChannelZ_entity_list.bin"

SECTION "bank23", ROMX[$4000], BANK[$23]
GexCave_1_collision_blockset:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_collision_blockset.bin"
GexCave_2_collision_blockset:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_collision_blockset.bin"
GexCave_3_collision_blockset:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_collision_blockset.bin"
GexCave_4_collision_blockset:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_collision_blockset.bin"
HolidayTV_1_collision_blockset:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_collision_blockset.bin"
HolidayTV_2_collision_blockset:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_collision_blockset.bin"
HolidayTV_4_collision_blockset:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_collision_blockset.bin"
MysteryTV_1_collision_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_collision_blockset.bin"
MysteryTV_2_collision_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_collision_blockset.bin"
MysteryTV_3_collision_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_collision_blockset.bin"
MysteryTV_4_collision_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_collision_blockset.bin"
MysteryTV_7_collision_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_collision_blockset.bin"
MysteryTV_8_collision_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_collision_blockset.bin"
TutTV_1_collision_blockset:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_collision_blockset.bin"
TutTV_2_collision_blockset:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_collision_blockset.bin"
TutTV_3_collision_blockset:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_collision_blockset.bin"
TutTV_4_collision_blockset:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_collision_blockset.bin"
TutTV_5_collision_blockset:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_collision_blockset.bin"
TutTV_6_collision_blockset:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_collision_blockset.bin"
TutTV_7_collision_blockset:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_collision_blockset.bin"
WesternStation_1_collision_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_collision_blockset.bin"
WesternStation_2_collision_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_collision_blockset.bin"
WesternStation_3_collision_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_collision_blockset.bin"
WesternStation_4_collision_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_collision_blockset.bin"
WesternStation_5_collision_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_collision_blockset.bin"
WesternStation_6_collision_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_collision_blockset.bin"
AnimeChannel_1_collision_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_collision_blockset.bin"
AnimeChannel_2_collision_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_collision_blockset.bin"
AnimeChannel_3_collision_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_collision_blockset.bin"
AnimeChannel_4_collision_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_collision_blockset.bin"
AnimeChannel_5_collision_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_collision_blockset.bin"
AnimeChannel_6_collision_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_collision_blockset.bin"
SuperheroShow_1_collision_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_collision_blockset.bin"
SuperheroShow_2_collision_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_collision_blockset.bin"
SuperheroShow_3_collision_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_collision_blockset.bin"
SuperheroShow_4_collision_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_collision_blockset.bin"
SuperheroShow_5_collision_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_collision_blockset.bin"
SuperheroShow_6_collision_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_collision_blockset.bin"
GextremeSports_1_collision_blockset:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_collision_blockset.bin"
MarsupialMadness_1_collision_blockset:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_collision_blockset.bin"
WWGexWrestling_1_collision_blockset:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_collision_blockset.bin"
LizardOfOz_1_collision_blockset:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_collision_blockset.bin"
ChannelZ_1_collision_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_collision_blockset.bin"
ChannelZ_2_collision_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_collision_blockset.bin"
ChannelZ_3_collision_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_collision_blockset.bin"
ChannelZ_4_collision_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_collision_blockset.bin"
ChannelZ_5_collision_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_collision_blockset.bin"

SECTION "bank24", ROMX[$4000], BANK[$24]
MysteryTV_1_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_blockset.bin"
MysteryTV_2_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_blockset.bin"
MysteryTV_3_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_blockset.bin"
MysteryTV_4_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_blockset.bin"
MysteryTV_7_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_blockset.bin"
MysteryTV_8_blockset:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_blockset.bin"
HolidayTV_1_blockset:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_blockset.bin"
HolidayTV_4_blockset:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_blockset.bin"
TutTV_6_blockset:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_blockset.bin"

SECTION "bank25", ROMX[$4000], BANK[$25]
HolidayTV_2_blockset:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_blockset.bin"
TutTV_1_blockset:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_blockset.bin"
TutTV_2_blockset:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_blockset.bin"
TutTV_3_blockset:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_blockset.bin"
TutTV_4_blockset:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_blockset.bin"
TutTV_5_blockset:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_blockset.bin"
TutTV_7_blockset:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_blockset.bin"
WesternStation_1_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_blockset.bin"
WesternStation_2_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_blockset.bin"
WesternStation_3_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_blockset.bin"
WesternStation_4_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_blockset.bin"
LizardOfOz_1_blockset:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_blockset.bin"

SECTION "bank26", ROMX[$4000], BANK[$26]
AnimeChannel_1_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_blockset.bin"
AnimeChannel_2_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_blockset.bin"
AnimeChannel_3_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_blockset.bin"
AnimeChannel_4_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_blockset.bin"
AnimeChannel_5_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_blockset.bin"
AnimeChannel_6_blockset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_blockset.bin"
SuperheroShow_1_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_blockset.bin"
SuperheroShow_2_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_blockset.bin"
SuperheroShow_3_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_blockset.bin"
SuperheroShow_4_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_blockset.bin"
SuperheroShow_5_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_blockset.bin"
SuperheroShow_6_blockset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_blockset.bin"

SECTION "bank27", ROMX[$4000], BANK[$27]
GextremeSports_1_blockset:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_blockset.bin"	
MarsupialMadness_1_blockset:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_blockset.bin"
ChannelZ_1_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_blockset.bin"
ChannelZ_2_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_blockset.bin"
ChannelZ_3_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_blockset.bin"
ChannelZ_4_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_blockset.bin"
ChannelZ_5_blockset:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_blockset.bin"
WesternStation_5_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_blockset.bin"

SECTION "bank28", ROMX[$4000], BANK[$28]
GexCave_1_blockset:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_blockset.bin"
GexCave_2_blockset:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_blockset.bin"
GexCave_3_blockset:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_blockset.bin"
GexCave_4_blockset:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_blockset.bin"	
WWGexWrestling_1_blockset:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_blockset.bin"
WesternStation_6_blockset:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_blockset.bin"

SECTION "bank29", ROMX[$4000], BANK[$29]
SECTION "bank2A", ROMX[$4000], BANK[$2A]
SECTION "bank2B", ROMX[$4000], BANK[$2B]
SECTION "bank2C", ROMX[$4000], BANK[$2C]
SECTION "bank2D", ROMX[$4000], BANK[$2D]

SECTION "bank2e", ROMX[$4000], BANK[$2e]
ChannelZ_1_map_extended:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_map_extended.bin"
ChannelZ_2_map_extended:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_map_extended.bin"
ChannelZ_3_map_extended:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_map_extended.bin"
ChannelZ_4_map_extended:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_map_extended.bin"
ChannelZ_5_map_extended:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_map_extended.bin"
WesternStation_1_map_extended:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_map_extended.bin"
junk_extended_data:
    INCBIN "data/maps/WesternStation/junk_extended_data.bin"
WesternStation_2_map_extended:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_map_extended.bin"
WesternStation_3_map_extended:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_map_extended.bin"
WesternStation_4_map_extended:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_map_extended.bin"
WesternStation_5_map_extended:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_map_extended.bin"
WesternStation_6_map_extended:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_map_extended.bin"

SECTION "bank2f", ROMX[$4000], BANK[$2f]
ChannelZ_1_map:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_map.bin"
ChannelZ_2_map:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_map.bin"
ChannelZ_3_map:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_map.bin"
ChannelZ_4_map:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_map.bin"
ChannelZ_5_map:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_map.bin"
WesternStation_1_map:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_map.bin"
junk_map_data:
    INCBIN "data/maps/WesternStation/junk_map_data.bin"
WesternStation_2_map:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_map.bin"
WesternStation_3_map:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_map.bin"
WesternStation_4_map:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_map.bin"
WesternStation_5_map:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_map.bin"
WesternStation_6_map:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_map.bin"

SECTION "bank30", ROMX[$4000], BANK[$30]
ChannelZ_1_collision:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_collision.bin"
ChannelZ_2_collision:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_collision.bin"
ChannelZ_3_collision:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_collision.bin"
ChannelZ_4_collision:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_collision.bin"
ChannelZ_5_collision:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_collision.bin"
WesternStation_1_collision:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_collision.bin"
junk_collision_data:
    INCBIN "data/maps/WesternStation/junk_collision_data.bin"
WesternStation_2_collision:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_collision.bin"
WesternStation_3_collision:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_collision.bin"
WesternStation_4_collision:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_collision.bin"
WesternStation_5_collision:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_collision.bin"
WesternStation_6_collision:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_collision.bin"

SECTION "bank31", ROMX[$4000], BANK[$31]
MysteryTV_1_map_extended:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_map_extended.bin"
MysteryTV_2_map_extended:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_map_extended.bin"
MysteryTV_3_map_extended:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_map_extended.bin"
MysteryTV_4_map_extended:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_map_extended.bin"
MysteryTV_7_map_extended:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_map_extended.bin"
MysteryTV_8_map_extended:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_map_extended.bin"
TutTV_1_map_extended:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_map_extended.bin"
TutTV_2_map_extended:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_map_extended.bin"
TutTV_3_map_extended:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_map_extended.bin"
TutTV_4_map_extended:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_map_extended.bin"
TutTV_5_map_extended:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_map_extended.bin"
TutTV_6_map_extended:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_map_extended.bin"
TutTV_7_map_extended:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_map_extended.bin"	
HolidayTV_2_map_extended:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_map_extended.bin"

SECTION "bank32", ROMX[$4000], BANK[$32]
MysteryTV_1_map:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_map.bin"
MysteryTV_2_map:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_map.bin"
MysteryTV_3_map:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_map.bin"
MysteryTV_4_map:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_map.bin"
MysteryTV_7_map:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_map.bin"
MysteryTV_8_map:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_map.bin"
TutTV_1_map:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_map.bin"
TutTV_2_map:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_map.bin"
TutTV_3_map:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_map.bin"
TutTV_4_map:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_map.bin"
TutTV_5_map:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_map.bin"
TutTV_6_map:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_map.bin"
TutTV_7_map:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_map.bin"	
HolidayTV_2_map:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_map.bin"

SECTION "bank33", ROMX[$4000], BANK[$33]
MysteryTV_1_collision:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_collision.bin"
MysteryTV_2_collision:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_collision.bin"
MysteryTV_3_collision:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_collision.bin"
MysteryTV_4_collision:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_collision.bin"
MysteryTV_7_collision:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_collision.bin"
MysteryTV_8_collision:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_collision.bin"
TutTV_1_collision:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_collision.bin"
TutTV_2_collision:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_collision.bin"
TutTV_3_collision:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_collision.bin"
TutTV_4_collision:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_collision.bin"
TutTV_5_collision:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_collision.bin"
TutTV_6_collision:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_collision.bin"
TutTV_7_collision:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_collision.bin"	
HolidayTV_2_collision:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_collision.bin"

SECTION "bank34", ROMX[$4000], BANK[$34]
HolidayTV_1_map_extended:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_map_extended.bin"
HolidayTV_4_map_extended:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_map_extended.bin"
MarsupialMadness_1_map_extended:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_map_extended.bin"
WWGexWrestling_1_map_extended:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_map_extended.bin"

SECTION "bank35", ROMX[$4000], BANK[$35]
HolidayTV_1_map:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_map.bin"
HolidayTV_4_map:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_map.bin"
MarsupialMadness_1_map:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_map.bin"
WWGexWrestling_1_map:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_map.bin"

SECTION "bank36", ROMX[$4000], BANK[$36]
HolidayTV_1_collision:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_collision.bin"
HolidayTV_4_collision:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_collision.bin"
MarsupialMadness_1_collision:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_collision.bin"
WWGexWrestling_1_collision:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_collision.bin"

SECTION "bank37", ROMX[$4000], BANK[$37]
AnimeChannel_1_map_extended:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_map_extended.bin"
AnimeChannel_2_map_extended:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_map_extended.bin"
AnimeChannel_3_map_extended:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_map_extended.bin"
AnimeChannel_4_map_extended:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_map_extended.bin"
AnimeChannel_5_map_extended:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_map_extended.bin"
AnimeChannel_6_map_extended:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_map_extended.bin"
LizardOfOz_1_map_extended:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_map_extended.bin"

SECTION "bank38", ROMX[$4000], BANK[$38]
AnimeChannel_1_map:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_map.bin"
AnimeChannel_2_map:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_map.bin"
AnimeChannel_3_map:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_map.bin"
AnimeChannel_4_map:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_map.bin"
AnimeChannel_5_map:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_map.bin"
AnimeChannel_6_map:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_map.bin"
LizardOfOz_1_map:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_map.bin"

SECTION "bank39", ROMX[$4000], BANK[$39]
AnimeChannel_1_collision:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_collision.bin"
AnimeChannel_2_collision:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_collision.bin"
AnimeChannel_3_collision:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_collision.bin"
AnimeChannel_4_collision:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_collision.bin"
AnimeChannel_5_collision:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_collision.bin"
AnimeChannel_6_collision:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_collision.bin"
LizardOfOz_1_collision:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_collision.bin"

SECTION "bank3a", ROMX[$4000], BANK[$3a]
SuperheroShow_2_map_extended:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_map_extended.bin"
GextremeSports_1_map_extended:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_map_extended.bin"

SECTION "bank3b", ROMX[$4000], BANK[$3b]
SuperheroShow_2_map:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_map.bin"
GextremeSports_1_map:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_map.bin"

SECTION "bank3c", ROMX[$4000], BANK[$3c]
SuperheroShow_2_collision:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_collision.bin"
GextremeSports_1_collision:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_collision.bin"

SECTION "bank3d", ROMX[$4000], BANK[$3d]
SuperheroShow_1_map_extended:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_map_extended.bin"
SuperheroShow_3_map_extended:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_map_extended.bin"
SuperheroShow_4_map_extended:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_map_extended.bin"
SuperheroShow_5_map_extended:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_map_extended.bin"
SuperheroShow_6_map_extended:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_map_extended.bin"
GexCave_1_map_extended:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_map_extended.bin"
GexCave_2_map_extended:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_map_extended.bin"
GexCave_3_map_extended:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_map_extended.bin"
GexCave_4_map_extended:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_map_extended.bin"

SECTION "bank3e", ROMX[$4000], BANK[$3e]
SuperheroShow_1_map:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_map.bin"
SuperheroShow_3_map:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_map.bin"
SuperheroShow_4_map:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_map.bin"
SuperheroShow_5_map:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_map.bin"
SuperheroShow_6_map:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_map.bin"
GexCave_1_map:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_map.bin"
GexCave_2_map:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_map.bin"
GexCave_3_map:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_map.bin"
GexCave_4_map:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_map.bin"

SECTION "bank3f", ROMX[$4000], BANK[$3f]
SuperheroShow_1_collision:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_collision.bin"
SuperheroShow_3_collision:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_collision.bin"
SuperheroShow_4_collision:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_collision.bin"
SuperheroShow_5_collision:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_collision.bin"
SuperheroShow_6_collision:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_collision.bin"
GexCave_1_collision:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_collision.bin"
GexCave_2_collision:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_collision.bin"
GexCave_3_collision:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_collision.bin"
GexCave_4_collision:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_collision.bin"

SECTION "bank40", ROMX[$4000], BANK[$40]
AnimeChannel_1_tileset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_tileset.bin"
AnimeChannel_2_tileset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_tileset.bin"
MarsupialMadness_1_tileset:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_tileset.bin"

SECTION "bank41", ROMX[$4000], BANK[$41]
WesternStation_3_tileset:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_tileset.bin"
AnimeChannel_4_tileset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_tileset.bin"
LizardOfOz_1_tileset:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_tileset.bin"

SECTION "bank42", ROMX[$4000], BANK[$42]
WesternStation_1_tileset:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_tileset.bin"
WesternStation_2_tileset:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_tileset.bin"

SECTION "bank43", ROMX[$4000], BANK[$43]
HolidayTV_1_tileset:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_tileset.bin"
HolidayTV_2_tileset:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_tileset.bin"

SECTION "bank44", ROMX[$4000], BANK[$44]
MysteryTV_1_tileset:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_tileset.bin"
MysteryTV_2_tileset:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_tileset.bin"
MysteryTV_4_tileset:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_tileset.bin"
MysteryTV_8_tileset:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_tileset.bin"

SECTION "bank45", ROMX[$4000], BANK[$45]
MysteryTV_3_tileset:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_tileset.bin"
MysteryTV_7_tileset:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_tileset.bin"
HolidayTV_4_tileset:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_tileset.bin"

SECTION "bank46", ROMX[$4000], BANK[$46]
TutTV_1_tileset:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_tileset.bin"
TutTV_2_tileset:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_tileset.bin"
TutTV_7_tileset:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_tileset.bin"

SECTION "bank47", ROMX[$4000], BANK[$47]
TutTV_3_tileset:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_tileset.bin"
TutTV_4_tileset:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_tileset.bin"
TutTV_5_tileset:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_tileset.bin"
SuperheroShow_5_tileset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_tileset.bin"

SECTION "bank48", ROMX[$4000], BANK[$48]
AnimeChannel_3_tileset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_tileset.bin"
AnimeChannel_5_tileset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_tileset.bin"

SECTION "bank49", ROMX[$4000], BANK[$49]
SuperheroShow_1_tileset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_tileset.bin"
SuperheroShow_2_tileset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_tileset.bin"

SECTION "bank4a", ROMX[$4000], BANK[$4a]
SuperheroShow_3_tileset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_tileset.bin"
SuperheroShow_4_tileset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_tileset.bin"
TutTV_6_tileset:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_tileset.bin"
SuperheroShow_6_tileset:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_tileset.bin"

SECTION "bank4b", ROMX[$4000], BANK[$4b]
WesternStation_4_tileset:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_tileset.bin"
WesternStation_5_tileset:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_tileset.bin"

SECTION "bank4c", ROMX[$4000], BANK[$4c]
ChannelZ_1_tileset:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_tileset.bin"
ChannelZ_2_tileset:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_tileset.bin"
ChannelZ_3_tileset:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_tileset.bin"
ChannelZ_5_tileset:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_tileset.bin"

SECTION "bank4d", ROMX[$4000], BANK[$4d]
AnimeChannel_6_tileset:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_tileset.bin"
GextremeSports_1_tileset:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_tileset.bin"
GexCave_4_tileset:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_tileset.bin"

SECTION "bank4e", ROMX[$4000], BANK[$4e]
GexCave_1_tileset:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_tileset.bin"
GexCave_2_tileset:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_tileset.bin"
GexCave_3_tileset:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_tileset.bin"

SECTION "bank4f", ROMX[$4000], BANK[$4f]
WWGexWrestling_1_tileset:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_tileset.bin"
ChannelZ_4_tileset:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_tileset.bin"
WesternStation_6_tileset:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_tileset.bin"

SECTION "bank50", ROMX[$4000], BANK[$50]
SECTION "bank51", ROMX[$4000], BANK[$51]
SECTION "bank52", ROMX[$4000], BANK[$52]
SECTION "bank53", ROMX[$4000], BANK[$53]
SECTION "bank54", ROMX[$4000], BANK[$54]
SECTION "bank55", ROMX[$4000], BANK[$55]
SECTION "bank56", ROMX[$4000], BANK[$56]
SECTION "bank57", ROMX[$4000], BANK[$57]
SECTION "bank58", ROMX[$4000], BANK[$58]
SECTION "bank59", ROMX[$4000], BANK[$59]
SECTION "bank5A", ROMX[$4000], BANK[$5A]
SECTION "bank5B", ROMX[$4000], BANK[$5B]
SECTION "bank5C", ROMX[$4000], BANK[$5C]
SECTION "bank5D", ROMX[$4000], BANK[$5D]
SECTION "bank5E", ROMX[$4000], BANK[$5E]
SECTION "bank5F", ROMX[$4000], BANK[$5F]
SECTION "bank60", ROMX[$4000], BANK[$60]
SECTION "bank61", ROMX[$4000], BANK[$61]

SECTION "bank62", ROMX[$4000], BANK[$62]
INCLUDE "data/player_sprite_data/bank62_frames.asm"
    INCBIN ".gfx/player_sprites/image_062_4840.bin", 0, $3740      ; 884 tiles, without the sheet's blank padding
SECTION "bank63", ROMX[$4000], BANK[$63]
INCLUDE "data/player_sprite_data/bank63_frames.asm"
    INCBIN ".gfx/player_sprites/image_063_4870.bin", 0, $3740      ; 884 tiles, without the sheet's blank padding
SECTION "bank64", ROMX[$4000], BANK[$64]
INCLUDE "data/player_sprite_data/bank64_frames.asm"
    INCBIN ".gfx/player_sprites/image_064_4880.bin", 0, $3760      ; 886 tiles, without the sheet's blank padding
SECTION "bank65", ROMX[$4000], BANK[$65]
INCLUDE "data/player_sprite_data/bank65_frames.asm"
    INCBIN ".gfx/player_sprites/image_065_41e0.bin", 0, $0c60      ; 198 tiles, without the sheet's blank padding
SECTION "bank66", ROMX[$4000], BANK[$66]
INCLUDE "data/player_sprite_data/bank66_frames.asm"
    INCBIN ".gfx/player_sprites/image_066_4530.bin", 0, $2300      ; 560 tiles, without the sheet's blank padding
SECTION "bank67", ROMX[$4000], BANK[$67]
INCLUDE "data/player_sprite_data/bank67_frames.asm"
    INCBIN ".gfx/player_sprites/image_067_47f0.bin", 0, $37a0      ; 890 tiles, without the sheet's blank padding
SECTION "bank68", ROMX[$4000], BANK[$68]
INCLUDE "data/player_sprite_data/bank68_frames.asm"
    INCBIN ".gfx/player_sprites/image_068_4820.bin", 0, $3760      ; 886 tiles, without the sheet's blank padding
SECTION "bank69", ROMX[$4000], BANK[$69]
INCLUDE "data/player_sprite_data/bank69_frames.asm"
    INCBIN ".gfx/player_sprites/image_069_4820.bin", 0, $3740      ; 884 tiles, without the sheet's blank padding
SECTION "bank6a", ROMX[$4000], BANK[$6a]
INCLUDE "data/player_sprite_data/bank6a_frames.asm"
    INCBIN ".gfx/player_sprites/image_06a_4820.bin", 0, $36e0      ; 878 tiles, without the sheet's blank padding
SECTION "bank6b", ROMX[$4000], BANK[$6b]
INCLUDE "data/player_sprite_data/bank6b_frames.asm"
    INCBIN ".gfx/player_sprites/image_06b_40b0.bin"
SECTION "bank6c", ROMX[$4000], BANK[$6c]
INCLUDE "data/player_sprite_data/bank6c_frames.asm"
    INCBIN ".gfx/player_sprites/image_06c_4830.bin", 0, $37c0      ; 892 tiles, without the sheet's blank padding
SECTION "bank6d", ROMX[$4000], BANK[$6d]
INCLUDE "data/player_sprite_data/bank6d_frames.asm"
    INCBIN ".gfx/player_sprites/image_06d_42d0.bin", 0, $12e0      ; 302 tiles, without the sheet's blank padding
SECTION "bank6e", ROMX[$4000], BANK[$6e]
INCLUDE "data/player_sprite_data/bank6e_frames.asm"
    INCBIN ".gfx/player_sprites/image_06e_4800.bin", 0, $3780      ; 888 tiles, without the sheet's blank padding
SECTION "bank6f", ROMX[$4000], BANK[$6f]
INCLUDE "data/player_sprite_data/bank6f_frames.asm"
    INCBIN ".gfx/player_sprites/image_06f_4830.bin", 0, $3700      ; 880 tiles, without the sheet's blank padding
SECTION "bank70", ROMX[$4000], BANK[$70]
INCLUDE "data/player_sprite_data/bank70_frames.asm"
    INCBIN ".gfx/player_sprites/image_070_4850.bin", 0, $3740      ; 884 tiles, without the sheet's blank padding
SECTION "bank71", ROMX[$4000], BANK[$71]
INCLUDE "data/player_sprite_data/bank71_frames.asm"
    INCBIN ".gfx/player_sprites/image_071_46c0.bin", 0, $2e60      ; 742 tiles, without the sheet's blank padding
SECTION "bank72", ROMX[$4000], BANK[$72]
INCLUDE "data/player_sprite_data/bank72_frames.asm"
    INCBIN ".gfx/player_sprites/image_072_4800.bin", 0, $3780      ; 888 tiles, without the sheet's blank padding
SECTION "bank73", ROMX[$4000], BANK[$73]
INCLUDE "data/player_sprite_data/bank73_frames.asm"
    INCBIN ".gfx/player_sprites/image_073_4830.bin", 0, $37a0      ; 890 tiles, without the sheet's blank padding
SECTION "bank74", ROMX[$4000], BANK[$74]
INCLUDE "data/player_sprite_data/bank74_frames.asm"
    INCBIN ".gfx/player_sprites/image_074_4840.bin", 0, $3720      ; 882 tiles, without the sheet's blank padding
SECTION "bank75", ROMX[$4000], BANK[$75]
INCLUDE "data/player_sprite_data/bank75_frames.asm"
    INCBIN ".gfx/player_sprites/image_075_41c0.bin", 0, $0b40      ; 180 tiles, without the sheet's blank padding
SECTION "bank76", ROMX[$4000], BANK[$76]
INCLUDE "data/player_sprite_data/bank76_frames.asm"
    INCBIN ".gfx/player_sprites/image_076_4830.bin", 0, $3780      ; 888 tiles, without the sheet's blank padding
SECTION "bank77", ROMX[$4000], BANK[$77]
INCLUDE "data/player_sprite_data/bank77_frames.asm"
    INCBIN ".gfx/player_sprites/image_077_4860.bin", 0, $3780      ; 888 tiles, without the sheet's blank padding
SECTION "bank78", ROMX[$4000], BANK[$78]
INCLUDE "data/player_sprite_data/bank78_frames.asm"
    INCBIN ".gfx/player_sprites/image_078_4750.bin", 0, $3040      ; 772 tiles, without the sheet's blank padding
SECTION "bank79", ROMX[$4000], BANK[$79]
INCLUDE "data/player_sprite_data/bank79_frames.asm"
    INCBIN ".gfx/player_sprites/image_079_4810.bin", 0, $3720      ; 882 tiles, without the sheet's blank padding
SECTION "bank7a", ROMX[$4000], BANK[$7a]
INCLUDE "data/player_sprite_data/bank7a_frames.asm"
    INCBIN ".gfx/player_sprites/image_07a_4860.bin", 0, $3760      ; 886 tiles, without the sheet's blank padding
SECTION "bank7b", ROMX[$4000], BANK[$7b]
INCLUDE "data/player_sprite_data/bank7b_frames.asm"
    INCBIN ".gfx/player_sprites/image_07b_4630.bin", 0, $26e0      ; 622 tiles, without the sheet's blank padding
SECTION "bank7c", ROMX[$4000], BANK[$7c]
INCLUDE "data/player_sprite_data/bank7c_frames.asm"
    INCBIN ".gfx/player_sprites/image_07c_4850.bin", 0, $3720      ; 882 tiles, without the sheet's blank padding
SECTION "bank7d", ROMX[$4000], BANK[$7d]
INCLUDE "data/player_sprite_data/bank7d_frames.asm"
    INCBIN ".gfx/player_sprites/image_07d_4890.bin", 0, $3720      ; 882 tiles, without the sheet's blank padding
SECTION "bank7e", ROMX[$4000], BANK[$7e]
INCLUDE "data/player_sprite_data/bank7e_frames.asm"
    INCBIN ".gfx/player_sprites/image_07e_4850.bin", 0, $35a0      ; 858 tiles, without the sheet's blank padding
SECTION "bank7f_player_sprite_data", ROMX[$4000], BANK[$7f]
INCLUDE "data/player_sprite_data/bank7f_player_sprite_data.asm"
