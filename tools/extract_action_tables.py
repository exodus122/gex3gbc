import os
import struct

object_names = [
    "Object_Gex"
]

bank002_data = open('./banks/bank_002.bin', 'rb').read()

# get list of jump tables, starts at 0x4000
jump_table_list_data = bank002_data[0x0000:0x07b4]
#print(jump_table_list_data)

# get the data at each of those

out = open('./banks/object_actions.asm', "w")

data_list_pointers = []

first = True
i = 0
while i < 0x6e:
    jump_table_ptr = struct.unpack('<H',jump_table_list_data[0x0000 + 2*i:0x0000 + 2*i + 2])[0]
    next_jump_table_ptr = struct.unpack('<H',jump_table_list_data[0x0000 + 2*(i+1):0x0000 + 2*(i+1) + 2])[0]
    #print("{:02x}".format(jump_table_ptr-0x4000)+", "+"{:02x}".format(next_jump_table_ptr-0x4000))
    
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
            
    first = False
    i = i + 1

out.close()


'''data_list_pointers.sort()
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