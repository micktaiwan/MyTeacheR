class Position

  # generate pseudo legal moves
  def gen_moves
    moves = []
    moves = gen_knights_moves(@side) + gen_rooks_moves(@side) + gen_bishops_moves(@side)
    moves
  end

private

  def gen_knights_moves(side)
    moves = []
    knights = @bitboards[side ? WHITE_KNIGHTS : BLACK_KNIGHTS]
    indexes(knights).each { |i|
			[-17, -15, -10, -6, 6, 10, 15, 17].each do |m|
				target = i+m
				if target >= 0 and target <= 63 and ((target % 8) - (i % 8)).abs < 3
					capture = piece_at(target)
					moves << [i, target] if !capture or side!=capture[1]
				end
			end
      }
    moves
  end

	def gen_rook_type_moves(side, index, start_limit = 8)
		moves = []
		rank = index / 8
		file = index % 8
		[-8,-1,1,8].each do |inc|
			limit = start_limit
			trying = index + inc
			while limit > 0 and trying >= 0 and trying <= 63 and
  			   (rank == (trying / 8) or file == (trying % 8)) do
				target = piece_at trying
				if !target
					moves << [index, trying]
				elsif side != target[1]
					moves << [index, trying]
					break
				else
					break
				end
				trying += inc
				limit -= 1
			end
		end
		moves
	end

	def gen_rooks_moves(side)
		moves = []
		rooks = @bitboards[ side ? WHITE_ROOKS : BLACK_ROOKS]
		indexes(rooks).each do |r|
			moves += gen_rook_type_moves( @side, r)
		end
		moves
	end

	def gen_bishop_type_moves(side, index, start_limit = 8)
		moves = []
		[-9,-7,7,9].each do |inc|
			limit = start_limit
			trying = index + inc
			rank = trying / 8
			lastrank = index / 8
			while limit > 0 and trying >= 0 and trying <= 63 and
			      (lastrank - rank).abs == 1 do
				target = piece_at trying
				if !target
					moves << [index, trying]
				elsif side!=target[1]
					moves << [index, trying]
					break
				else
					break
				end
				lastrank  = rank
				trying   += inc
				rank      = trying / 8
				limit    -= 1
			end
		end
		moves
	end

	def gen_bishops_moves white
		moves = []
		bishops = @bitboards[white ? WHITE_BISHOPS : BLACK_BISHOPS]
		indexes(bishops).each do |r|
			moves += gen_bishop_type_moves(@side, r)
		end
		moves
	end
end

