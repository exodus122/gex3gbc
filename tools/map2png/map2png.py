import PIL.Image # type: ignore
import PIL.ImageDraw # type: ignore
import numpy # type: ignore
import struct
import os
from enum import Enum

# enum for LevelData
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
LEVEL_ID = 20 # I think this is level id?
PADDING = 21 # I think this is always $00?

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
    #print(bank03_data[p-0x4000:p-0x4000+0x1F])
    p = level_data_pointers[level_counter]
    level_data = struct.unpack("<BHBHBHBHBHBHBHBHBHBBBB", bank03_data[p-0x4000:p-0x4000+0x1F])
    if [level_data[BLOCKSET_AND_PALETTE_IDS_BANK], level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]] not in blockset_offsets:
        blockset_offsets.append([level_data[BLOCKSET_AND_PALETTE_IDS_BANK], level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]])
    if [level_data[MAP_BANK], level_data[MAP_BANK_OFFSET]] not in map_offsets:
        map_offsets.append([level_data[MAP_BANK], level_data[MAP_BANK_OFFSET]])
    if [level_data[TILESET_BANK], level_data[TILESET_BANK_OFFSET]] not in tileset_offsets:
        tileset_offsets.append([level_data[TILESET_BANK], level_data[TILESET_BANK_OFFSET]])

print("Blockset Offsets:")
sorted_blockset_offsets = sorted(blockset_offsets, key=lambda x: (x[0], x[1]))
for b in sorted_blockset_offsets:
    print(f"{b[0]:0{2}x}"+": "+f"{b[1]:0{4}x}")

print("\nMap Offsets:")
sorted_map_offsets = sorted(map_offsets, key=lambda x: (x[0], x[1]))
for b in sorted_map_offsets:
    print(f"{b[0]:0{2}x}"+": "+f"{b[1]:0{4}x}")

print("\nTileset Offsets:")
sorted_tileset_offsets = sorted(tileset_offsets, key=lambda x: (x[0], x[1]))
for b in sorted_tileset_offsets:
    print(f"{b[0]:0{2}x}"+": "+f"{b[1]:0{4}x}")

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

for level_counter in range(0, len(level_data_pointers)):
    #print(bank03_data[p-0x4000:p-0x4000+0x1F])
    p = level_data_pointers[level_counter]
    level_data = struct.unpack("<BHBHBHBHBHBHBHBHBHBBBB", bank03_data[p-0x4000:p-0x4000+0x1F])
    for d in level_data:
        print(hex(d))

    level_name = "TEST"
    channel_map_number = str(level_counter)

    tiles = []
    blocks = []
    
    
    #os.system('mkdir -p tileset_bins')
    #os.system('mkdir -p tileset_images')

    

    #out = open('./tileset_bins/tileset_'+level_name+channel_map_number+'.bin', "wb")
    #out.write(tile_data)
    #out.close()
    #os.system('rgbgfx --reverse 1 -o ./tileset_bins/tileset_'+level_name+channel_map_number+'.bin tileset_images/tileset_'+level_name+channel_map_number+'.png')

    #print(tile_data)

    '''count = 0
    for i in range(0, len(tile_data), 0x10):
        data = tile_data[i:i + 0x10]
        if not data:
            break
        
        out = open('./tile_bins/'+level_name+channel_map_number+'/tile_'+f"{count:0{2}x}"+'.bin', "wb")
        out.write(data)
        out.close()
        
        #palette_index = palette_ids[count]
        #print(palette_index)
        #temp_palette_data = palette_data[0x8*palette_index:0x8*palette_index+0x8]
        #f = open("./temp.bin", "wb")
        #f.write(temp_palette_data)
        #f.close()
        
        # -p '+"./temp.bin"+'
        os.system('rgbgfx --reverse 1  --columns -o ./tile_bins/'+level_name+channel_map_number+'/tile_'+f"{count:0{2}x}"+'.bin ./tile_bins/'+level_name+channel_map_number+'/tile_'+f"{count:0{2}x}"+'.png')
        
        count = count + 1
    
    os.system('mkdir -p tileset_images')
    new_tileset_img = PIL.Image.new("RGB", (128, 128))
    count = 0
    for y in range(0, 16):
        for x in range(0, 16):
            try:
                tile_img = PIL.Image.open('./tile_bins/'+level_name+channel_map_number+'/tile_'+f"{count:0{2}x}"+'.png')
            except:
                continue
            new_tileset_img.paste(tile_img, (x*8, y*8))
            tiles.append(tile_img)
            count = count + 1
    new_tileset_img.save('./tileset_images/'+level_name+channel_map_number+'_tileset.png')

    os.system('rm -r tile_bins')'''
    # create the colored block images using the palette data, blockset_data and tileset_data
    tileset_file = "../banks/bank_0"+f"{level_data[TILESET_BANK]:x}"+".bin"
    end_addr = get_next_offset(sorted_tileset_offsets, [level_data[TILESET_BANK], level_data[TILESET_BANK_OFFSET]])
    tileset_data = open(tileset_file, 'rb').read()[level_data[TILESET_BANK_OFFSET]-0x4000:end_addr-0x4000]

    blockset_file = "../banks/bank_0"+f"{level_data[BLOCKSET_AND_PALETTE_IDS_BANK]:x}"+".bin"
    end_addr = get_next_offset(sorted_blockset_offsets, [level_data[BLOCKSET_AND_PALETTE_IDS_BANK], level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]])
    blockset_data = open(blockset_file, "rb").read()[level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]-0x4000:end_addr-0x4000]

    os.system('mkdir -p block_bins')
    os.system('mkdir -p block_bins/'+level_name+channel_map_number)
    count = 0
    for i in range(0, len(blockset_data), 0x8):
        block_data = blockset_data[i:i + 0x8]
        if not block_data:
            break
        
        out = open('./block_bins/'+level_name+channel_map_number+'/block_'+f"{count:0{2}x}"+'.bin', "wb")
        out.write(tileset_data[block_data[0]*0x10:block_data[0]*0x10+0x10])
        out.write(tileset_data[block_data[2]*0x10:block_data[2]*0x10+0x10])
        out.write(tileset_data[block_data[1]*0x10:block_data[1]*0x10+0x10])
        out.write(tileset_data[block_data[3]*0x10:block_data[3]*0x10+0x10])
        out.close()
        
        '''palette_index = palette_ids[count]
        #print(palette_index)
        temp_palette_data = palette_data[0x8*palette_index:0x8*palette_index+0x8]
        f = open("./temp.bin", "wb")
        f.write(temp_palette_data)
        f.close()'''
        
        # -p '+"./temp.bin"+'
        os.system('rgbgfx --reverse 2  --columns -o ./block_bins/'+level_name+channel_map_number+'/block_'+f"{count:0{2}x}"+'.bin ./block_bins/'+level_name+channel_map_number+'/block_'+f"{count:0{2}x}"+'.png')
        
        block_img = PIL.Image.open('./block_bins/'+level_name+channel_map_number+'/block_'+f"{count:0{2}x}"+'.png')
        blocks.append(block_img)

        count = count + 1

    # create the level's blockset from the tileset
    '''blockset_file = "../banks/bank_0"+f"{level_data[BLOCKSET_AND_PALETTE_IDS_BANK]:x}"+".bin"
    blockset_data = open(blockset_file, "rb").read()[level_data[BLOCKSET_AND_PALETTE_IDS_BANK_OFFSET]-0x4000:]
    #print(blockset_data)

    os.system('mkdir -p blockset_images')
    #os.system('mkdir -p block_images')
    
    blockset_image_path = "./blockset_images/"
    
    blockset_img = PIL.Image.new("RGB", (256, 256))
    draw2 = PIL.ImageDraw.Draw(blockset_img)
    
    draw_block_ids = False

    block_counter = 0
    for y in range(0, 16):
        for x in range(0, 16):
            #draw2.rectangle(((x*32,y*32), ((x+1)*32,(y+1)*32)), 0,3)
            
            block_img =  PIL.Image.new("RGB", (16, 16))
            draw3 = PIL.ImageDraw.Draw(block_img)
            
            # add the regular tiles to the blockset
            val = block_counter*8
            tile_counter = 0
            for inner_y in range(0, 2):
                for inner_x in range(0, 2):
                    #blockset_img.paste(tiles[blockset_data[block_counter]], (x*32, y*32))
                    
                    try:
                        block_img.paste(tiles[blockset_data[val]], (inner_x*8, inner_y*8))
                    except:
                        continue
                    val = val + 0x1
                    tile_counter = tile_counter + 1
            
            if draw_block_ids == True:
                draw3.text((0, 0), "0x%02X" % block_counter, "magenta")
            
            #block_img.save("./block_images/block"+str(block_counter)+".png")
            blockset_img.paste(block_img, (x*16, y*16))
            
            block_counter = block_counter + 1
    
    blockset_img.save(blockset_image_path+level_name+channel_map_number+"_blockset.png")'''

    # build map from map data and blockset image
    map_file = "../banks/bank_0"+f"{level_data[MAP_BANK]:x}"+".bin"
    #blockset_image_path = "./scream_tv_blockset.png"
    width = level_data[MAP_WIDTH]
    height = level_data[MAP_HEIGHT]
    offset = level_data[MAP_BANK_OFFSET]
    #print(map_file)
    #map_bank_data = open(map_file, "rb").read()
    #print(map_bank_data)

    os.system('mkdir -p map_images')
        
    map_image_path = "./map_images/"
    
    #blockset_img = PIL.Image.open(blockset_image_path)
    
    #blockset = []
    #for y in range(0, 16):
    #    for x in range(0, 16):
    #        blockset.append(blockset_img.crop((x*16, y*16, (x+1)*16, (y+1)*16)))

    map_data = open(map_file, "rb").read()[offset-0x4000:offset-0x4000+width*height]
    #print(data)
    
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
    
    img.save(map_image_path+level_name+channel_map_number+"_map.png")

    os.system('rm -r block_bins')

    #break # just do first one for testing
