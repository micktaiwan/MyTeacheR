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
    gen_knights_moves(side) +
    gen_rooks_moves(side) +
    gen_bishops_moves(side) +
    gen_queens_moves(side) +
    gen_pawns_moves(side) +
    gen_king_moves(side)
  end

  def gen_legal_captures(side=@side)
    m = gen_moves(side)
    m = m.select { |m| m.capture != nil }
    prune_king_revealers(side,m)
  end

# private

  def knight_attackers(index, side)
		piece = colored_piece(KNIGHT, 1-side)
    indexes(@knight_attacks[index] & @bitboards[piece]).map {|i| [piece, i]}
  end

  def rook_attackers(index, side)
		piece1 = colored_piece(ROOK, 1-side)
		piece2 = colored_piece(QUEEN, 1-side)
		rm = rook_moves(index)
    rv = []
    for i in indexes(rm & @bitboards[piece1])
			rv << [piece1, i]
    end
    for i in indexes(rm & @bitboards[piece2])
			rv << [piece2, i]
    end
    rv
  end

  def bishop_attackers(index, side)
		attackers = []
    for inc in [-9,-7,7,9]
      limit = 7
      target = index + inc
      rank = target / 8
      lastrank = index / 8
      while limit > 0 and target >= 0 and target <= 63 and
            (lastrank - rank).abs == 1 do
        capture = piece_at(target)
        if capture
          if side != color(capture)
            pt = piece_type(capture)
            if pt == BISHOP or pt == QUEEN
              attackers << [colored_piece(pt,1-side), target]
              break
            else
              break
            end
          else
            break
          end
        end
        lastrank  = rank
        target   += inc
        rank      = target / 8
        limit    -= 1
      end
    end
    attackers
  end

  def queen_attackers(index, side)
  	rook_attackers(index, side) + bishop_attackers(index, side)
  end

  def gen_knights_moves(side)
    moves = []
    other_color_or_empty = (side == WHITE ? ~@all_whites : ~@all_blacks)
    piece = colored_piece(KNIGHT,side)
    for i in indexes(@bitboards[colored_piece(KNIGHT,side)])
      for target in indexes(@knight_attacks[i] & other_color_or_empty)
        moves << Move.new(piece, i, target, piece_at(target))
      end
    end
    moves
  end

  def rank_occupancy(index)
    (@all_pieces & @rank_mask[index]) >> @rank_shift[index]
  end

  def file_occupancy(index)
    (((@all_pieces & @file_mask[index]) * @file_magic[index]) >> 57) & FILE_OCCUPANCY_MASK
  end

  def flipDiagA8H1(bb)
   t   =       bb ^ (bb << 36)
   bb ^= K4 & ( t ^ (bb >> 36))
   t   = K2 & (bb ^ (bb << 18))
   bb ^=        t ^ ( t >> 18)
   t   = K1 & (bb ^ (bb <<  9))
   bb ^=        t ^ ( t >>  9)
  end

  def flipVertical(bb)
    return  ( (bb << 56)                        ) |
            ( (bb << 40) & (0x00ff000000000000) ) |
            ( (bb << 24) & (0x0000ff0000000000) ) |
            ( (bb <<  8) & (0x000000ff00000000) ) |
            ( (bb >>  8) & (0x00000000ff000000) ) |
            ( (bb >> 24) & (0x0000000000ff0000) ) |
            ( (bb >> 40) & (0x000000000000ff00) ) |
            ( (bb >> 56) )
  end

  # http://chessprogramming.wikispaces.com/Flipping+Mirroring+and+Rotating#The whole Bitboard-Rotating-By 90 degrees Clockwise
  def rotate(bb)
    flipDiagA8H1(flipVertical(bb))
  end

  def rook_moves(index)
    @rook_attacks[index%8][rank_occupancy(index)]  << (@rank_shift[index] - 1) |
    rotate(@rook_attacks[7-index/8][file_occupancy(index)]) << index % 8
  end

  def gen_rook_type_moves(side, index, piece)
    moves = []
    other_color_or_empty = (side == WHITE ? ~@all_whites : ~@all_blacks)
    cpiece = colored_piece(piece,side)
    for target in indexes(rook_moves(index) & other_color_or_empty)
      moves << Move.new(cpiece, index, target, piece_at(target))
    end
    moves
  end

  def gen_rooks_moves(side)
    moves = []
    rooks = @bitboards[colored_piece(ROOK,side)]
    for r in indexes(rooks)
      moves += gen_rook_type_moves(side, r, ROOK)
    end
    moves
  end

  def gen_bishop_type_moves(side, index, piece, start_limit = 7)
    moves = []
    for inc in [-9,-7,7,9]
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
    for r in indexes(bishops)
      moves += gen_bishop_type_moves(side, r, BISHOP)
    end
    moves
  end

  def gen_queens_moves(side)
		moves = []
		queens = @bitboards[colored_piece(QUEEN,side)]
		for r in indexes(queens)
			moves += gen_rook_type_moves(side, r, QUEEN)
			moves += gen_bishop_type_moves(side, r, QUEEN)
		end
		moves
	end

	def pawn_attackers(index, side)
		rv = []
	  if(side == WHITE)
	    rv << [BPAWN, index+7] if(index % 8 != 0 and index+7 < 63 and piece_at(index+7) == BPAWN)
	    rv << [BPAWN, index+9] if(index % 8 != 7 and index+9 < 63 and piece_at(index+9) == BPAWN)
	  else
	    rv << [WPAWN, index-7]  if(index % 8 != 7 and index-7 > 0 and piece_at(index-7) == WPAWN)
	    rv << [WPAWN, index-9]  if(index % 8 != 0 and index-9 > 0 and piece_at(index-9) == WPAWN)
	  end
	  rv
	end

	def gen_pawns_moves(side)
		if side==BLACK
			in_front_int      = -8
			second_rank_high  = 56
			second_rank_low   = 47
			two_away_int      = -16
			attack_left       = -9
			attack_right      = -7
			promote_low       = -1
			promote_high      = 8
			promotes          = [BQUEEN, BROOK, BBISHOP, BKNIGHT]
		else
			in_front_int      = 8
			second_rank_high  = 16
			second_rank_low   = 7
			two_away_int      = 16
			attack_left       = 7
			attack_right      = 9
			promote_low       = 55
			promote_high      = 64
			promotes          = [WQUEEN, WROOK, WBISHOP, WKNIGHT]
		end
		moves = []
		for p in indexes(@bitboards[colored_piece(PAWN, side)])
			in_front = piece_at(p+in_front_int)
			#single step + promotion
			if !in_front
				in_front_pos = p + in_front_int
				if in_front_pos > promote_low and in_front_pos < promote_high
					for piece in promotes
            moves << Move.new(colored_piece(PAWN,side),p,in_front_pos, nil, piece)
					end
				else
  				moves << Move.new(colored_piece(PAWN,side),p,in_front_pos)
				end
			end
			#double jump
			if p < second_rank_high and p > second_rank_low and !in_front and !piece_at(p+two_away_int)
        moves << Move.new(colored_piece(PAWN,side),p, p+two_away_int)
			end
			#captures
			unless p % 8 == 0 # we're in the a file
				ptarget = piece_at( p + attack_left)
				if ptarget and side != color(ptarget)
				  if p + attack_left > promote_low and p + attack_left < promote_high
				    # promotions while capturing
					  for piece in promotes
              moves << Move.new(colored_piece(PAWN,side),p,p+attack_left, ptarget, piece)
					  end
					else
            moves << Move.new(colored_piece(PAWN,side),p, p+attack_left, ptarget)
				  end
				end
			end
			unless p % 8 == 7 # we're in the h file
				ptarget = piece_at( p + attack_right)
				if ptarget and side != color(ptarget)
				  if p + attack_right > promote_low and p + attack_right < promote_high
				    # promotions while capturing
					  for piece in promotes
              moves << Move.new(colored_piece(PAWN,side),p,p + attack_right, ptarget, piece)
					  end
					else
            moves << Move.new(colored_piece(PAWN,side),p, p+attack_right, ptarget)
				  end
				end
			end
			# generate en-passant
			if @bitboards[ENPASSANT] != 0
				passant = indexes(@bitboards[ENPASSANT]).first
				if ((p + attack_right) == passant and p % 8 != 7) or ((p + attack_left) == passant and p % 8 != 0)
          moves << Move.new(colored_piece(PAWN,side),p, p+attack_right)
				end
			end
		end
		moves
	end

	def gen_castle_moves(side, king_index)
		goodcastles = []
		# kingside
		kpiece = colored_piece(KING,side)
		if can_castle(side, KINGSIDE)
			test = if(side==BLACK) then [60,61,62]; else [4,5,6] end

		  if !piece_at(test[1]) and !piece_at(test[2]) # TODO: something like if (!(maskF1G1 & ~occupiedSquares))
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

		  if !piece_at(test[1]) and !piece_at(test[2]) and !piece_at(extra) # TODO: something like if (!(maskF1G1 & ~occupiedSquares))
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
      king = indexes(@bitboards[kpiece]).first
      if in_check?(king,side)
        rv = false
      else
        rv = true
      end

			#next_moves = gen_moves(1-side) # TODO: replace by the "reverse the perspective" method
			#king = indexes(@bitboards[kpiece]).first
			#select_ret = true
			#for m in next_moves
			#	if m.to == king
			#	  #puts "king captured! #{m} #{m.inspect}"
			#		select_ret = false
			#		break
			#	end
			#end

			unmake
			rv
		end
	end

	def king_attackers(index, side)
		piece = colored_piece(KING, 1-side)
		indexes(@king_attacks[index] & @bitboards[piece]).map {|i| [piece, i]}
	end

	# return an array of [piece, index]
	def get_attackers(index, side)
		queen_attackers(index, side) +
		knight_attackers(index, side) +
		pawn_attackers(index, side) +
		king_attackers(index, side)
	end

	def in_check?(index, side)
	  return true if get_attackers(index, side)[0]
	  return false
	end

	def gen_king_moves(side)
		king_i = indexes(@bitboards[colored_piece(KING, side)]).first
		#raise "No king ???" if !king_i
		moves = []
		for target in indexes(@king_attacks[king_i] & (side == WHITE ? ~@all_whites : ~@all_blacks))
      moves << Move.new(colored_piece(KING, side), king_i, target, piece_at(target))
  	end
		moves += gen_castle_moves(side, king_i)
		moves
	end

end

