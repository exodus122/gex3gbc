import os

def extract_banks():
    os.system('mkdir -p banks/')
    with open('../rom.gb', 'rb') as bf:
        count = 0
        for data in iter(lambda: bf.read(0x4000), ''):
            if not data:
                break
            
            out = open('./banks/bank_'+f"{count:0{3}x}"+'.bin', "wb")
            out.write(data)
            out.close()
            count = count + 1

def extract_bank_1f():
    
    banks = [0x1f]
    size1 = [0x300]
    size2 = [0x30]
    size3 = [0x20]
    width = [0x8]
    
    chunk_counter = 0
    i = 0
    while i < len(banks):
        b = banks[i]
        bank = f"{b:0{3}x}"
        with open('./banks/bank_'+bank+'.bin', 'rb') as bf:
            addr = 0x4000
             
            next_chunk = size1[i]
            width = width[i]
            
            os.system('mkdir -p banks/bank_'+bank+'/')
            os.system('mkdir -p banks/bank_'+bank+'/palette_ids/')
            os.system('mkdir -p banks/bank_'+bank+'/palettes/')
            chunk_counter = 0
            count2 = 0
            for data in iter(lambda: bf.read(next_chunk), ''):
                
                #print(str(chunk_counter)+". next chunk is: "+f"{next_chunk:0{4}x}"+" and addr is "+f"{addr:0{4}x}")
                addr_str = f"{addr:0{4}x}"
                if not data:
                    break
                
                if chunk_counter % 3 == 0:
                    out = open('./banks/bank_'+bank+'/image_'+bank+'_'+f"{count2:02d}"+".bin", "wb")
                elif chunk_counter % 3 == 1:
                    out = open('./banks/bank_'+bank+'/palette_ids/image_'+bank+'_'+f"{count2:02d}"+"_palette_ids.bin", "wb")
                elif chunk_counter % 3 == 2:
                    out = open('./banks/bank_'+bank+'/palettes/image_'+bank+'_'+f"{count2:02d}"+"_palette.bin", "wb")
                out.write(data)
                out.close()
                
                if chunk_counter % 3 == 0:
                    os.system('rgbgfx --reverse '+str(width)+' -o banks/bank_'+bank+'/image_'+bank+'_'+f"{count2:02d}"+'.bin banks/bank_'+bank+'/image_'+bank+'_'+f"{count2:02d}"+'.png')
                
                out2 = open('./banks/bank_'+bank+'/text.txt', "a")
                if chunk_counter % 3 == 0:
                    out2.write('image_'+bank+'_'+f"{count2:02d}"+'.bin:\n    INCBIN \"../.gfx/secondary_tilesets/image_'+bank+'_'+f"{count2:02d}"+'.bin\"\n')
                elif chunk_counter % 3 == 1:
                    out2.write('image_'+bank+'_'+f"{count2:02d}"+'_palette_ids.bin:\n    INCBIN \"../gfx/secondary_tilesets/palette_ids/image_'+bank+'_'+f"{count2:02d}"+'_palette_ids.bin\"\n')
                elif chunk_counter % 3 == 2:
                    out2.write('image_'+bank+'_'+f"{count2:02d}"+'_palette.bin:\n    INCBIN \"../gfx/secondary_tilesets/palettes/image_'+bank+'_'+f"{count2:02d}"+'_palette.bin\"\n')
                out2.close()
                
                if chunk_counter % 3 == 0:
                    next_chunk = size2[i]
                    addr = addr + next_chunk
                elif chunk_counter % 3 == 1:
                    next_chunk = size3[i]
                    addr = addr + next_chunk
                else:
                    next_chunk = size1[i]
                    addr = addr + next_chunk
                    count2 = count2 + 1
                
                chunk_counter = chunk_counter + 1
        i = i + 1

def extract_object_sprites():
    banks = ["007", "007", "008", "009", "00a", "00a", "00b", "00c", "00d", "00e", "00f", "010", "01d", "01e"]
    banks2 = ["07", "07", "08", "09", "0a", "0a", "0b", "0c", "0d", "0e", "0f", "10", "1d", "1e"]
    addrs = [0x4000, 0x5B00, 0x4000, 0x4000, 0x4000, 0x6000, 0x4000, 0x4000, 0x4000, 0x4000, 0x4000, 0x4000, 0x4000, 0x4000]
    sizes = [0x1B00, 0xA00, 0x2b80, 0x3f00, 0x2000, 0x2000, 0x4000, 0x4000, 0x4000, 0x4000, 0x4000, 0x4000, 0x3f00, 0x4000]
    widths = [0x48, 0xA, 0x74,  0xa8, 0x100, 0x100, 0x100, 0x100, 0x100, 0x100, 0x100, 0x80, 0xa8, 0x80]
    
    for i in range(0, len(addrs)):
        bank = banks[i]
        bank2 = banks2[i]
        bank_data = open('./banks/bank_'+bank+'.bin', 'rb').read()
        os.system('mkdir -p banks/bank_'+bank+'/')
        
        addr = addrs[i]
        addr_str = f"{addr:0{4}x}"
        
        data = bank_data[addr-0x4000:addr-0x4000+sizes[i]]
        width = widths[i]
        out = open('./banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.bin', "wb")
        out.write(data)
        out.close()
        
        if i != 1:
            os.system('rgbgfx --reverse '+str(width)+' --columns -o banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.bin banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.png')
        else:
            os.system('rgbgfx --reverse '+str(width)+' -o banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.bin banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.png')

        out2 = open('./banks/bank_'+bank+'/text.txt', "a")
        out2.write('data_'+bank2+'_'+addr_str+':\n    INCBIN \"./.gfx/object_sprites/image_'+bank+'_'+addr_str+'.bin\"\n')
        out2.close()

def extract_bank_06():
    bank = "006"
    bank2 = "06"
    bank_data = open('./banks/bank_'+bank+'.bin', 'rb').read()
    os.system('mkdir -p banks/bank_'+bank+'/')
    
    # extract menu images
    names = ["", "_bgmap_tile_ids", "_palette_ids", "", "_bgmap_tile_ids", "_palette_ids", 
             "", "_bgmap_tile_ids", "_palette_ids", "", "_bgmap_tile_ids", "_palette_ids", 
             "", "_bgmap_tile_ids", "_palette_ids", "", "_bgmap_tile_ids", "_palette_ids"]
    names2 = ["", "/bgmap_tile_ids", "/palette_ids", "", "/bgmap_tile_ids", "/palette_ids", 
              "", "/bgmap_tile_ids", "/palette_ids", "", "/bgmap_tile_ids", "/palette_ids",
              "", "/bgmap_tile_ids", "/palette_ids", "", "/bgmap_tile_ids", "/palette_ids"]
    sizes = [0x5e0, 0x168, 0x5e, 0x100, 0x168, 0x10, 0xce0, 0x168, 0x168, 
             0x500, 0x168, 0x50, 0x580, 0x168, 0x58, 0x3a0, 0x168, 0x3a]
    widths = [47, 0, 0, 8, 0, 0, 103, 0, 0, 8, 0, 0, 22, 0, 0, 29, 0, 0]
    image_flags = [True, False, False, True, False, False, True, False, False, 
                   True, False, False, True, False, False, True, False, False]
    
    addr = 0x4000
    for i in range(0, len(sizes)):
        if image_flags[i] == True:
            addr_str = f"{addr:0{4}x}"
        
        data = bank_data[addr-0x4000:addr-0x4000+sizes[i]]
        #width = int((addrs[i+1] - addr) / 0x10)
        width = widths[i]
        out = open('./banks/bank_'+bank+'/image_'+bank+'_'+addr_str+names[i]+'.bin', "wb")
        out.write(data)
        out.close()
        
        if image_flags[i] == True:
            os.system('rgbgfx --reverse '+str(width)+' -o banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.bin banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.png')
        
        out2 = open('./banks/bank_'+bank+'/text.txt', "a")
        out2.write('image_'+bank2+'_'+addr_str+names[i]+':\n    INCBIN \"./gfx/menus'+names2[i]+'/image_'+bank+'_'+addr_str+names[i]+'.bin\"\n')
        out2.close()

        addr = addr + sizes[i]

def extract_bank_11():
    bank = "011"
    bank2 = "11"
    bank_data = open('./banks/bank_'+bank+'.bin', 'rb').read()
    os.system('mkdir -p banks/bank_'+bank+'/')
    
    # extract menu images
    names = ["", "_bgmap_tile_ids", "_palette_ids"]
    names2 = ["", "/bgmap_tile_ids", "/palette_ids"]
    sizes = [0x1190, 0x168, 0x168]
    widths = [281, 0, 0]
    image_flags = [True, False, False]
    
    addr = 0x4000
    for i in range(0, len(sizes)):
        if image_flags[i] == True:
            addr_str = f"{addr:0{4}x}"
        
        data = bank_data[addr-0x4000:addr-0x4000+sizes[i]]
        #width = int((addrs[i+1] - addr) / 0x10)
        width = widths[i]
        out = open('./banks/bank_'+bank+'/image_'+bank+'_'+addr_str+names[i]+'.bin', "wb")
        out.write(data)
        out.close()
        
        if image_flags[i] == True:
            os.system('rgbgfx --reverse '+str(width)+' -o banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.bin banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.png')
        
        out2 = open('./banks/bank_'+bank+'/text.txt', "a")
        out2.write('image_'+bank2+'_'+addr_str+names[i]+':\n    INCBIN \"./gfx/menus'+names2[i]+'/image_'+bank+'_'+addr_str+names[i]+'.bin\"\n')
        out2.close()

        addr = addr + sizes[i]

def extract_tilesets():
    os.system('mkdir -p banks/')
    os.system('mkdir -p banks/tilesets/')
    for b in range(0x40, 0x50):
        bank = f"{b:0{3}x}"
        bank_data = open('./banks/bank_'+bank+'.bin', 'rb').read()
        os.system('rgbgfx --reverse 16 -o banks/bank_'+bank+'.bin banks/tilesets/tileset_'+bank+'.png')

def extract_bank_03():
    # extracts the 3 images at the top of bank 03
    bank = "003"
    bank2 = "03"
    os.system('mkdir -p banks/bank_'+bank+'/')

    bgcollision_tileset_img_bin = open('./banks/bank_'+bank+'.bin', 'rb').read()[0x0100:0x0400]
    out = open('./banks/bank_'+bank+'/image_'+bank+'_4100.bin', "wb")
    out.write(bgcollision_tileset_img_bin)
    out.close()
    os.system('rgbgfx --reverse 16 -d 1 -o banks/bank_'+bank+'/image_'+bank+'_4100.bin banks/bank_'+bank+'/image_'+bank+'_4100.png')


    pawprint_img_bin = open('./banks/bank_'+bank+'.bin', 'rb').read()[0x400:0x580]
    out = open('./banks/bank_'+bank+'/image_'+bank+'_4400.bin', "wb")
    out.write(pawprint_img_bin)
    out.close()
    os.system('rgbgfx --reverse 12 --columns -o banks/bank_'+bank+'/image_'+bank+'_4400.bin banks/bank_'+bank+'/image_'+bank+'_4400.png')

    numbers_img_bin = open('./banks/bank_'+bank+'.bin', 'rb').read()[0x580:0x6E0]
    out = open('./banks/bank_'+bank+'/image_'+bank+'_4580.bin', "wb")
    out.write(numbers_img_bin)
    out.close()
    os.system('rgbgfx --reverse 11 --columns -o banks/bank_'+bank+'/image_'+bank+'_4580.bin banks/bank_'+bank+'/image_'+bank+'_4580.png')

def extract_bank_01():
    # extracts the images at the bottom of bank 01
    bank = "001"
    bank2 = "01"
    os.system('mkdir -p banks/bank_'+bank+'/')
    starts = [0x5c79, 0x6069, 0x64e9, 0x66f9, 0x6f48]
    ends = [0x6069, 0x64e9, 0x66f9, 0x6f39, 0x70a8]
    widths = [63, 8, 33, 66, 11]

    for i in range(0, len(starts)):
        addr = starts[i]
        addr_str = f"{addr:0{4}x}"
        img_bin = open('./banks/bank_'+bank+'.bin', 'rb').read()[addr-0x4000:ends[i]-0x4000]
        out = open('./banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.bin', "wb")
        out.write(img_bin)
        out.close()
        os.system('rgbgfx --reverse '+str(widths[i])+' --columns -o banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.bin banks/bank_'+bank+'/image_'+bank+'_'+addr_str+'.png')

#extract_banks()
extract_object_sprites()
#extract_bank_1f()
#extract_bank_06()
#extract_bank_11()
#extract_tilesets()
#extract_bank_03()
#extract_bank_01()
