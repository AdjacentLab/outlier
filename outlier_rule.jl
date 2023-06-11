#
# Outlier rule represented as 512 bits lookup table
#
# code and example usage
#
# for non-Julia coders:
# array index starts at 1 in Julia. other things should be self-explanatory
#
# the functions are written only for illustrative purposes, but they are functional.
#

const OUTLIER_HEX = "111e111b144eebb41079234f151ad6ee111e2d171904dad0ef86b5e8e7ca4c40131d10881679e80a10682534a156861240692a952cada74bf8b086621315a0f2"

# returns the 512 bits lookup table of the Outlier rule, as arrays of 64 bytes
outlier_rule() = hex2bytes(OUTLIER_HEX)


# lookup() returns the next state of the center cell, true for live and false for dead
#
# the cell states of Moore neighborhood are bit-encoded as the lowest 9 bits in u9
# see next function for ordering

function lookup(table::Vector{UInt8}, u9::UInt16)
    # split the 9 bit neighborhood states into 2 parts: 6 bits and 3 bits
    high_bits, low_bits = (u9 >> 3, u9 & 0x7)

    # high_bits points to the byte in the lookup table
    tbl_byte = table[1+ high_bits]

    # low_bits points to the bit location within the byte. from highest bit:
    mask = 0x80 >> low_bits

    # center cell is to be alive when this bit is on
    return  tbl_byte & mask > 0x0
end


# state of neighborhood cells in s0 through s8.  they can be bool or any other type
# as long as UInt16(s*) returns 0x1 (for live) or 0x0 (for dead)
#
# s1: top left, s2: top, s3: top right, s4: right;
# s5: down right, s6: down, s7: down left, s8: left
# s0: center cell

function lookup(table::Vector{UInt8}, s1, s2, s3, s4, s5, s6, s7, s8, s0)
    u9 = UInt16(s1) 
    for (i, s) in enumerate((s2, s3, s4, s5, s6, s7, s8, s0))
        # i will be 1, 2, ... 8
        u9 |= UInt16(s) << i
    end
    return lookup(table, u9)
end


### example usage
#
# rt = outlier_rule()
# next_state = lookup(rt, true, true, false, true, true, false, false, true, true)
#   or
# next_state = lookup(rt, 0b0000000110011011)
#

