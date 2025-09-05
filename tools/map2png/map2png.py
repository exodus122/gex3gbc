import PIL.Image # type: ignore
import PIL.ImageDraw # type: ignore
import numpy # type: ignore
import struct
import os
from enum import Enum

def get_next_offset(arr, entry):
    for i, (a, b) in enumerate(arr):
        if [a, b] == entry:
            if i + 1 < len(arr):
                next_a, next_b = arr[i + 1]
                if next_a == a:
                    return next_b
                else:
                    return 0x8000
            else:
                # last element, nothing after
                return 0x8000
    print(str(entry) + " not in " + str(arr))
    raise ValueError("Entry not found in array")

def _x_flip_byte(byte_val):
    """Reverses the order of bits in a single byte."""
    # Convert integer to an 8-bit binary string (e.g., 0b10101011)
    # [2:] slices off the '0b' prefix
    # .zfill(8) pads with leading zeros to ensure it's 8 bits
    binary_str = bin(byte_val)[2:].zfill(8)
    
    # Reverse the string and convert back to an integer
    return int(binary_str[::-1], 2)

def x_flip_tile(tile_data):
    """
    Flips a single Game Boy tile (16 bytes) horizontally.

    Args:
        tile_data: A bytes object of exactly 16 bytes.

    Returns:
        A new bytes object with the tile data flipped horizontally.
    """
    if len(tile_data) != 16:
        raise ValueError("Tile data must be exactly 16 bytes.")

    flipped_bytes = []
    for byte_val in tile_data:
        flipped_bytes.append(_x_flip_byte(byte_val))
    
    return bytes(flipped_bytes)

def y_flip_tile(tile_data):
    """
    Flips a single Game Boy tile (16 bytes) vertically.

    Args:
        tile_data: A bytes object of exactly 16 bytes.

    Returns:
        A new bytes object with the tile data flipped vertically.
    """
    if len(tile_data) != 16:
        raise ValueError("Tile data must be exactly 16 bytes.")

    flipped_bytes = bytearray(16)
    for i in range(8):
        # A row is represented by two bytes.
        row_start = i * 2
        
        # The new row position is the reversed position.
        flipped_row_start = (7 - i) * 2
        
        # Copy the two bytes for the row to the new position.
        flipped_bytes[flipped_row_start] = tile_data[row_start]
        flipped_bytes[flipped_row_start + 1] = tile_data[row_start + 1]
    
    return bytes(flipped_bytes)

# enum for level_data
MAP_BANK = 0
MAP_BANK_OFFSET = 1
EXTENDED_MAP_BANK = 2
EXTENDED_MAP_BANK_OFFSET = 3
TILESET_BANK = 4
TILESET_BANK_OFFSET = 5
BLOCKSET_AND_PALETTE_IDS_BANK = 6
BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET = 7
BLOCK_COLLISION_BANK = 8
BLOCK_COLLISION_BANK_OFFSET = 9
PLAYER_SPAWNS_BANK = 10
PLAYER_SPAWNS_BANK_OFFSET = 11
BG_PALETTE_BANK = 12
BG_PALETTE_BANK_OFFSET = 13
OBJECT_SPAWN_LIST_BANK = 14
OBJECT_SPAWN_LIST_BANK_OFFSET = 15
COLLECTIBLE_LIST_BANK = 16
COLLECTIBLE_LIST_BANK_OFFSET = 17
MAP_WIDTH = 18 # width of map (in blocks)
MAP_HEIGHT = 19 # height of map (in blocks)
LEVEL_ID = 20
PADDING = 21 # always $00

level_names = ["GexCave", "HolidayTV", "MysteryTV", "TutTV", "WesternStation", "AnimeChannel", 
               "SuperheroShow", "GextremeSports", "MarsupialMadness", "WWGexWrestling",
               "LizardOfOz", "ChannelZ"]
level_numbers = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

# get level data pointers from bank03
bank03_file = "../banks/bank_003.bin"
bank03_data = open(bank03_file, "rb").read()

level_data_pointers = struct.unpack("<"+"H"*61, bank03_data[0x2ca0:0x2d1a])
#for p in level_data_pointers:
#    print(hex(p))

# loop through the pointers and get data for each
blockset_offsets = [] # list of banks and offsets in the blockset banks
map_offsets = []
tileset_offsets = []

for level_counter in range(0, len(level_data_pointers)):
    p = level_data_pointers[level_counter]
    level_data = struct.unpack("<BHBHBHBHBHBHBHBHBHBBBB", bank03_data[p-0x4000:p-0x4000+0x1F])
    if [level_data[BLOCKSET_AND_PALETTE_IDS_BANK], level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]] not in blockset_offsets:
        blockset_offsets.append([level_data[BLOCKSET_AND_PALETTE_IDS_BANK], level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]])
    if [level_data[MAP_BANK], level_data[MAP_BANK_OFFSET]] not in map_offsets:
        map_offsets.append([level_data[MAP_BANK], level_data[MAP_BANK_OFFSET]])
    if [level_data[TILESET_BANK], level_data[TILESET_BANK_OFFSET]] not in tileset_offsets:
        tileset_offsets.append([level_data[TILESET_BANK], level_data[TILESET_BANK_OFFSET]])

#print("Blockset Offsets:")
sorted_blockset_offsets = sorted(blockset_offsets, key=lambda x: (x[0], x[1]))
#for b in sorted_blockset_offsets:
#    print(f"{b[0]:0{2}x}"+": "+f"{b[1]:0{4}x}")

#print("\nMap Offsets:")
sorted_map_offsets = sorted(map_offsets, key=lambda x: (x[0], x[1]))
#for b in sorted_map_offsets:
#    print(f"{b[0]:0{2}x}"+": "+f"{b[1]:0{4}x}")

#print("\nTileset Offsets:")
sorted_tileset_offsets = sorted(tileset_offsets, key=lambda x: (x[0], x[1]))
#for b in sorted_tileset_offsets:
#    print(f"{b[0]:0{2}x}"+": "+f"{b[1]:0{4}x}")

generate_regular_maps = True
generate_collision_maps = False

if generate_regular_maps:
    for level_counter in range(0, len(level_data_pointers)):
        
        ptr = level_data_pointers[level_counter]
        level_data = struct.unpack("<BHBHBHBHBHBHBHBHBHBBBB", bank03_data[ptr-0x4000:ptr-0x4000+0x1F])
        #for d in level_data:
        #    print(hex(d))

        level_name = level_names[level_data[LEVEL_ID]]
        level_numbers[level_data[LEVEL_ID]] += 1
        channel_map_number = level_numbers[level_data[LEVEL_ID]]

        blocks = []
        
        # create the colored block images using the palette data, blockset_data and tileset_data
        tileset_file = "../banks/bank_0"+f"{level_data[TILESET_BANK]:x}"+".bin"
        end_addr = get_next_offset(sorted_tileset_offsets, [level_data[TILESET_BANK], level_data[TILESET_BANK_OFFSET]])
        tileset_data = open(tileset_file, 'rb').read()[level_data[TILESET_BANK_OFFSET]-0x4000:end_addr-0x4000]

        blockset_file = "../banks/bank_0"+f"{level_data[BLOCKSET_AND_PALETTE_IDS_BANK]:x}"+".bin"
        end_addr = get_next_offset(sorted_blockset_offsets, [level_data[BLOCKSET_AND_PALETTE_IDS_BANK], level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]])
        blockset_data = open(blockset_file, "rb").read()[level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]-0x4000:end_addr-0x4000]

        palette_file = "../banks/bank_0"+f"{level_data[BG_PALETTE_BANK]:x}"+".bin"
        palette_data = open(palette_file, 'rb').read()[level_data[BG_PALETTE_BANK_OFFSET]-0x4000:level_data[BG_PALETTE_BANK_OFFSET]-0x4000+0x40]

        os.system('mkdir -p tile_bins')
        
        for i in range(0, len(blockset_data), 0x8):
            block_data = blockset_data[i:i + 0x8]
            if not block_data:
                break
            
            tiles = []

            for j in range(0, 4):
                vram_offset = 0x0000
                if block_data[j+4] & 0x08: # if alternate vram bank bit is set
                    vram_offset = 0x1000
                tile_data = tileset_data[vram_offset+block_data[j]*0x10:vram_offset+block_data[j]*0x10+0x10]
                if block_data[j+4] & 0x20:
                    tile_data = x_flip_tile(tile_data)
                if block_data[j+4] & 0x40:
                    tile_data = y_flip_tile(tile_data)
                out = open('./tile_bins/tile_'+f"{j:0{2}x}"+'.bin', "wb")
                out.write(tile_data)
                out.close()
                
                palette_index = block_data[j+4] & 0x7
                temp_palette_data = palette_data[0x8*palette_index:0x8*palette_index+0x8]
                f = open("./temp.bin", "wb")
                f.write(temp_palette_data)
                f.close()
                os.system('rgbgfx --reverse 1 -p ./temp.bin --columns -o ./tile_bins/tile_'+f"{j:0{2}x}"+'.bin ./tile_bins/tile_'+f"{j:0{2}x}"+'.png')

                tile_img = PIL.Image.open('./tile_bins/tile_'+f"{j:0{2}x}"+'.png')
                tiles.append(tile_img)

            block_img =  PIL.Image.new("RGB", (16, 16))
            block_img.paste(tiles[0], (0, 0))
            block_img.paste(tiles[1], (8, 0))
            block_img.paste(tiles[2], (0, 8))
            block_img.paste(tiles[3], (8, 8))
            blocks.append(block_img)

        # build map from map data and blockset
        map_file = "../banks/bank_0"+f"{level_data[MAP_BANK]:x}"+".bin"
        width = level_data[MAP_WIDTH]
        height = level_data[MAP_HEIGHT]
        offset = level_data[MAP_BANK_OFFSET]

        os.system('mkdir -p map_images')
        os.system('mkdir -p map_images/'+level_name)

        map_image_path = "./map_images/"

        map_data = open(map_file, "rb").read()[offset-0x4000:offset-0x4000+width*height]
        
        extended_map_file = "../banks/bank_0"+f"{level_data[EXTENDED_MAP_BANK]:x}"+".bin"
        extended_map_data = open(extended_map_file, "rb").read()[level_data[EXTENDED_MAP_BANK_OFFSET]-0x4000:]

        count = 0
        img = PIL.Image.new("RGB", (16*width, 16*height))
        draw = PIL.ImageDraw.Draw(img)
        for y in range(0, height):
            for x in range(0, width):
                draw.rectangle(((x*16,y*16), ((x+1)*16,(y+1)*16)), map_data[count],3)
                
                img.paste(blocks[map_data[count] + 0x100 * extended_map_data[count]], (x*16, y*16))
                
                count = count+1
        
        img.save(map_image_path+level_name+"/"+level_name+"_"+f"{channel_map_number:0{2}}"+"_map.png")

        os.system('rm -r tile_bins')
        print("completed: "+level_name+"/"+level_name+"_"+f"{channel_map_number:0{2}}"+"_map.png")

        #break # just do first one for testing

if generate_collision_maps:

    # create collision tileset
    bg_collision_tiles = []
    collision_tileset_data = bank03_data[0x0000:0x0400]
    
    tileset_img = PIL.Image.new("RGB", (128, 128))
    draw2 = PIL.ImageDraw.Draw(tileset_img)
    
    tile_counter = 0
    for y in range(0, 16):
        for x in range(0, 16):
            tile_img =  PIL.Image.new("RGB", (8, 8), "white")
            draw3 = PIL.ImageDraw.Draw(tile_img)
            
            color = "black"
            '''flags = collision_tileset_data[0x800 + tile_counter]
            if flags & 0x03 == 0x3: # wall and ceiling flag?
                color = "red"
            elif flags & 0x02 == 0x2: # ceiling flag?
                color = "orange"
            elif flags & 0x01 == 0x1: # wall flag?
                color = "blue"'''
            
            row_count = 0
            while row_count < 4:
                data = collision_tileset_data[row_count*0x100 + tile_counter]
                if data & 0x80:
                    draw3.point((0,row_count), color)
                if data & 0x40:
                    draw3.point((1,row_count), color)
                if data & 0x20:
                    draw3.point((2,row_count), color)
                if data & 0x10:
                    draw3.point((3,row_count), color)
                if data & 0x08:
                    draw3.point((4,row_count), color)
                if data & 0x04:
                    draw3.point((5,row_count), color)
                if data & 0x02:
                    draw3.point((6,row_count), color)
                if data & 0x01:
                    draw3.point((7,row_count), color);
                
                row_count = row_count + 1
            
            bg_collision_tiles.append(tile_img)
            tileset_img.paste(tile_img, (x*8, y*8))
            
            #draw2.rectangle(((x*8, y*8), ((x+1)*8, (y+1)*8)), None, "pink")
            
            tile_counter = tile_counter + 1
    
    tileset_img.save("bg_collision_tileset.png")

    for level_counter in range(0, len(level_data_pointers)):
    
        ptr = level_data_pointers[level_counter]
        level_data = struct.unpack("<BHBHBHBHBHBHBHBHBHBBBB", bank03_data[ptr-0x4000:ptr-0x4000+0x1F])
        #for d in level_data:
        #    print(hex(d))

        level_name = level_names[level_data[LEVEL_ID]]
        level_numbers[level_data[LEVEL_ID]] += 1
        channel_map_number = level_numbers[level_data[LEVEL_ID]]

        blocks = []

        # create collision blocks

