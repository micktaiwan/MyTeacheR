class Position

  # generate pseudo legal moves
  def gen_moves
    gen_knights_moves(@side) + gen_rooks_moves(@side) + gen_bishops_moves(@side) +
    gen_queens_moves(@side) +
    gen_pawn_moves(@side)
  end

private

  def colored_piece(piece, side)
    piece + (side == BLACK ? BLACKS_OFFSET : 0)
  end

  def color(piece)
    return WHITE if piece <= PAWN
    return BLACK
  end

  def gen_knights_moves(side)
    moves = []
    knights = @bitboards[colored_piece(KNIGHT,side)]
    indexes(knights).each { |i|
      [-17, -15, -10, -6, 6, 10, 15, 17].each do |m|
        target = i+m
        if target >= 0 and target <= 63 and ((target % 8) - (i % 8)).abs < 3
          capture = piece_at(target)
          moves << Move.new(colored_piece(KNIGHT,side), i, target, capture) if !capture or side!=color(capture)
        end
      end
      }
    moves
  end

  def gen_rook_type_moves(side, index, piece, start_limit = 8)
    moves = []
    rank = index / 8
    file = index % 8
    [-8,-1,1,8].each do |inc|
      limit = start_limit
      target = index + inc
      while limit > 0 and target >= 0 and target <= 63 and
           (rank == (target / 8) or file == (target % 8)) do
        capture = piece_at(target)
        if !capture or side != color(capture)
          moves << Move.new(colored_piece(piece,side), index, target, capture)
        else
          break
        end
        target += inc
        limit -= 1
      end
    end
    moves
  end

  def gen_rooks_moves(side)
    moves = []
    rooks = @bitboards[colored_piece(ROOK,side)]
    indexes(rooks).each do |r|
      moves += gen_rook_type_moves(@side, r, ROOK)
    end
    moves
  end

  def gen_bishop_type_moves(side, index, piece, start_limit = 8)
    moves = []
    [-9,-7,7,9].each do |inc|
      limit = start_limit
      target = index + inc
      rank = target / 8
      lastrank = index / 8
      while limit > 0 and target >= 0 and target <= 63 and
            (lastrank - rank).abs == 1 do
        capture = piece_at(target)
        if !capture or side != color(capture)
          moves << Move.new(colored_piece(piece,side), index, target, capture)
        else
          break
        end
        lastrank  = rank
        target   += inc
        rank      = target / 8
        limit    -= 1
      end
    end
    moves
  end

  def gen_bishops_moves(side)
    moves = []
    bishops = @bitboards[colored_piece(BISHOP,side)]
    indexes(bishops).each do |r|
      moves += gen_bishop_type_moves(side, r, BISHOP)
    end
    moves
  end

  def gen_queens_moves(side)
		moves = []
		queens = @bitboards[colored_piece(QUEEN,side)]
		indexes(queens).each do |r|
			moves += gen_rook_type_moves(side, r, QUEEN)
			moves += gen_bishop_type_moves(side, r, QUEEN)
		end
		moves
	end

	def gen_pawn_moves(side)
		pawns = @bitboards[colored_piece(PAWN, side)]
		if side==BLACK
			in_front_int = -8
			second_rank_high = 56
			second_rank_low = 47
			two_away_int = -16
			attack_left = -9
			attack_right = -7
			promote_low = -1
			promote_high = 8
			promotes = [BROOK, BQUEEN, BKNIGHT, BBISHOP]
		else
			in_front_int = 8
			second_rank_high = 16
			second_rank_low = 7
			two_away_int = 16
			attack_left = 7
			attack_right = 9
			promote_low = 55
			promote_high = 64
			promotes = [WROOK, WQUEEN, WKNIGHT, WBISHOP]
		end
		do_pawn = Proc.new do |p|
			possible = []
			in_front = piece_at( p + in_front_int)
			#single step + promotion
			if  !in_front
				in_front_pos = p + in_front_int
				possible << Move.new(colored_piece(PAWN,side),p,in_front_pos)
				if in_front_pos > promote_low and in_front_pos < promote_high
					promotes.each { |piece|
            possible << Move.new(colored_piece(PAWN,side),p,in_front_pos, nil, piece)
					  }
				end
			end
			#double jump
			if p < second_rank_high and p > second_rank_low and !in_front and
			   !piece_at( p + two_away_int)
        possible << Move.new(colored_piece(PAWN,side),p, p+two_away_int)
			end
			#captures
			unless p % 8 == 0 # we're in the a file
				ptarget = piece_at( p + attack_left)
				if ptarget and side != color(ptarget)
				  if p + attack_left > promote_low and p + attack_left < promote_high
				    # promotions while capturing
					  promotes.each { |piece|
              possible << Move.new(colored_piece(PAWN,side),p,p+attack_left, ptarget, piece)
					    }
					else
            possible << Move.new(colored_piece(PAWN,side),p, p+attack_left, ptarget)
				  end
				end
			end
			unless p % 8 == 7 # we're in the h file
				ptarget = piece_at( p + attack_right)
				if ptarget and side != color(ptarget)
				  if p + attack_right > promote_low and p + attack_right < promote_high
				    # promotions while capturing
					  promotes.each { |piece|
              possible << Move.new(colored_piece(PAWN,side),p,p + attack_right, ptarget, piece)
					    }
					else
            possible << Move.new(colored_piece(PAWN,side),p, p+attack_right, ptarget)
				  end
				end
			end
			#check en-passant
			if @bitboards[ENPASSANT] != 0
				passant = indexes(@bitboards[ENPASSANT]).first
				if (p + attack_right) == passant or (p + attack_left) == passant
          possible << Move.new(colored_piece(PAWN,side),p, p+attack_right)
				end
			end
			possible
		end
		moves = []
		indexes(pawns).each do |p|
			moves += do_pawn.call(p)
		end
		moves
	end

end

