class Position

  def init_attacks
    init_knight_attacks
    init_king_attacks
    init_rook_attacks
  end

  def init_knight_attacks
    @knight_attacks = Array.new
    (0..63).each { |i|
      @knight_attacks[i] = 0
      [-17, -15, -10, -6, 6, 10, 15, 17].each do |m|
        target = i+m
        @knight_attacks[i] |= (1 << target) if target >= 0 and target <= 63 and ((target % 8) - (i % 8)).abs < 3
      end
      }
  end

	def init_king_attacks
    @king_attacks = Array.new
    (0..63).each { |i|
      @king_attacks[i] = 0
      [-1, 1, -7, -8, -9, 7, 8, 9].each do |m|
        target = i+m
        @king_attacks[i] |= (1 << target) if target >= 0 and target <= 63 and ((target % 8) - (i % 8)).abs < 3
      end
      }
	end

  # only one bit set
  def init_bitset
    @bitset = Array.new
    @bitset[0] = 0x1
    (1..63).each { |i|
      @bitset[i] = @bitset[i-1] << 1
      }
  end

  def init_ranks_and_files
    @rank_mask = Array.new
    @file_mask = Array.new
    (0..7).each { |rank|
    (0..7).each { |file|
    @rank_mask[file+rank*8] = @bitset[1+rank*8] | @bitset[2+rank*8] | @bitset[3+rank*8] |
                              @bitset[4+rank*8] | @bitset[5+rank*8] | @bitset[6+rank*8]
    @file_mask[file+rank*8] = @bitset[file+1*8] | @bitset[file+2*8] | @bitset[file+3*8] |
                              @bitset[file+4*8] | @bitset[file+5*8] | @bitset[file+6*8]
    }}
  end

  def init_rank_shift
    @rank_shift = Array.new
    (0..7).each { |rank|
    (0..7).each { |file|
      @rank_shift[file+rank*8] = rank*8 + 1
      #puts "#{file+rank*8}: #{@rank_shift[file+rank*8]}"
      }}
  end

  def init_file_magic
    magic = Array.new
    magic[0] = 0x8040201008040200
    magic[1] = 0x4020100804020100
    magic[2] = 0x2010080402010080
    magic[3] = 0x1008040201008040
    magic[4] = 0x0804020100804020
    magic[5] = 0x0402010080402010
    magic[6] = 0x0201008040201008
    magic[7] = 0x0100804020100804
    @file_magic = Array.new
    (0..7).each { |rank|
    (0..7).each { |file|
      @file_magic[file+rank*8] = magic[file]
      }}
  end

	def init_rook_attacks
    init_bitset
    init_file_magic
    init_rank_shift
    init_ranks_and_files
    init_char_bitset
    init_rank_file_attacks
	end

  def init_rank_file_attacks
    @rook_attacks = Array.new
    (0..7).each { |i|
      @rook_attacks[i] = Array.new
      (0..63).each { |state6Bit|
        state8Bit = state6Bit << 1 # create an 8-bit occupancy state
        attack8Bit = 0
        attack8Bit |= @char_bitset[i+1] if (i < 7)
        slide = i + 2
        while (slide <= 7) # slide in '+' direction
          break if ((~state8Bit) & (@char_bitset[slide-1]) == 0)
          attack8Bit |= @char_bitset[slide]
          slide += 1
        end
        attack8Bit |= @char_bitset[i-1] if (i > 0)
        slide = i - 2
        while (slide >= 0) # slide in '-' direction
          break if ((~state8Bit) & (@char_bitset[slide+1]) == 0)
          attack8Bit |= @char_bitset[slide]
          slide -= 1
        end
        @rook_attacks[i][state6Bit] = attack8Bit
        #puts "#{i}: #{state6Bit.to_s(2)} =>  #{attack8Bit.to_s(2)}"
        }
      }
  end

  # initialize CHARBITSET, this array is equivalant to BITSET for bitboards:
  # 8 chars, each with only 1 bit set.
  def init_char_bitset
    @char_bitset = Array.new
    @char_bitset[0] = 1
    (1..7).each { |i|
      @char_bitset[i] = @char_bitset[i-1] << 1
      }
  end

end

