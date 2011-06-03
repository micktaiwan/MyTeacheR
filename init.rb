class Position

  def init_attacks
    init_knight_attacks
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

end

Position.new.init_knight_attacks

