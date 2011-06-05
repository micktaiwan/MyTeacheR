# almost everything comes from "RubyKight" code

class Position

	# generate only legal moves
	def gen_legal_moves_2(side=@side)
		moves = gen_moves(side)
		nb = moves.size
		moves = prune_king_revealers(side,moves)
		to_del = nb-moves.size
		puts "pseudo moves: #{nb} - #{to_del} = #{moves.size} legal moves" if to_del > 0
		moves
	end

	def gen_legal_moves(side=@side)
		prune_king_revealers(side,gen_moves(side))
	end

  # generate pseudo legal moves
  def gen_moves(side=@side)
    m = gen_knights_moves(side) +
        gen_rooks_moves(side) +
        gen_bishops_moves(side) +
        gen_queens_moves(side) +
        gen_pawns_moves(side) +
        gen_king_moves(side)
    m.sort_by { |m| m.score }
  end

  def gen_legal_captures(side=@side)
    m = gen_moves(side)
    m = m.select { |m| m.capture != nil }
    prune_king_revealers(side,m)
  end

# private

  def gen_knights_moves(side)
    moves = []
    indexes(@bitboards[colored_piece(KNIGHT,side)]).each { |i|
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

  def gen_rook_type_moves(side, index, piece, start_limit = 7)
    moves = []
    rank = index / 8
    file = index % 8
    [-8,-1,1,8].each do |inc|
      limit = start_limit
      target = index + inc
      while limit > 0 and target >= 0 and target <= 63 and
           (rank == (target / 8) or file == (target % 8)) do
        capture = piece_at(target)
        if !capture
          moves << Move.new(colored_piece(piece,side), index, target, capture)
          #puts "inc=#{inc}, limit=#{limit}, target=#{index_to_case(target)}"# if piece == ROOK
        elsif side != color(capture)
          moves << Move.new(colored_piece(piece,side), index, target, capture)
          break
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
      #puts "==== #{index_to_case(r)}"
      moves += gen_rook_type_moves(side, r, ROOK)
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
        if !capture
          moves << Move.new(colored_piece(piece,side), index, target, capture)
        elsif side != color(capture)
          moves << Move.new(colored_piece(piece,side), index, target, capture)
          break
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

	def gen_pawns_moves(side)
		pawns = @bitboards[colored_piece(PAWN, side)]
		if side==BLACK
			in_front_int      = -8
			second_rank_high  = 56
			second_rank_low   = 47
			two_away_int      = -16
			attack_left       = -9
			attack_right      = -7
			promote_low       = -1
			promote_high      = 8
			promotes          = [BROOK, BQUEEN, BKNIGHT, BBISHOP]
		else
			in_front_int      = 8
			second_rank_high  = 16
			second_rank_low   = 7
			two_away_int      = 16
			attack_left       = 7
			attack_right      = 9
			promote_low       = 55
			promote_high      = 64
			promotes          = [WROOK, WQUEEN, WKNIGHT, WBISHOP]
		end
		do_pawn = Proc.new do |p|
			possible = []
			in_front = piece_at(p+in_front_int)
			#single step + promotion
			if !in_front
				in_front_pos = p + in_front_int
				if in_front_pos > promote_low and in_front_pos < promote_high
					promotes.each { |piece|
            possible << Move.new(colored_piece(PAWN,side),p,in_front_pos, nil, piece)
					  }
				else
  				possible << Move.new(colored_piece(PAWN,side),p,in_front_pos)
				end
			end
			#double jump
			if p < second_rank_high and p > second_rank_low and !in_front and !piece_at(p+two_away_int)
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
			# generate en-passant
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

	def gen_castle_moves(side, king_index)
		goodcastles = []
		# kingside
		kpiece = colored_piece(KING,side)
		if can_castle(side, KINGSIDE)
			test = if(side==BLACK) then [60,61,62]; else [4,5,6] end

		  if !piece_at(test[1]) and !piece_at(test[2])
  		  # FIXME: repeated code
			  left = prune_king_revealers(side, test.map {|dest| Move.new(kpiece, king_index, dest)})
			  goodcastles << Move.new(kpiece, king_index, test.last) if left.size == test.size
		  end

		end

		# queenside
		if can_castle(side, QUEENSIDE)
			if(side==BLACK)
			  test = [60,59,58]
			  extra = 57
			else
			  test = [4,3,2]
			  extra = 1
			end

		  if !piece_at(test[1]) and !piece_at(test[2]) and !piece_at(extra)
  		  # FIXME: repeated code
			  left = prune_king_revealers(side, test.map {|dest| Move.new(kpiece, king_index, dest)})
        goodcastles << Move.new(kpiece, king_index, test.last) if left.size == test.size
		  end

		end
    #puts "I have #{goodcastles.size} goodcastles" if goodcastles.size > 0
		goodcastles
	end

	def prune_king_revealers(side, moves)
	  #puts "prune_king_revealers: #{side}, #{moves.size} moves"
		kpiece = colored_piece(KING,side)
		moves.select do |m|
			make(m)
			next_moves = gen_moves(1-side)
			king = indexes(@bitboards[kpiece])[0]
			select_ret = true
			next_moves.each do |m|
				if m.to == king
					select_ret = false
					break
				end
			end
			unmake
			select_ret
		end
	end

	def gen_king_moves(side)
		moves = []
		king_i = indexes(@bitboards[colored_piece(KING, side)])[0]
		return [] if king_i == nil
		moves += gen_rook_type_moves(side, king_i, KING, 1)
		moves += gen_bishop_type_moves(side, king_i, KING, 1)
		moves += gen_castle_moves(side, king_i)
		moves
	end

end

