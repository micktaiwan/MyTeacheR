class Position

  def init_attacks
    init_knight_attacks
    init_king_attacks
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

end

