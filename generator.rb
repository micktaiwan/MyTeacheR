class Position

  # generate pseudo legal moves
  def gen_moves
    gen_knights_moves(@side) + gen_rooks_moves(@side) + gen_bishops_moves(@side)
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

  def gen_rook_type_moves(side, index, start_limit = 8)
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
          moves << Move.new(colored_piece(ROOK,side), index, target, capture)
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
      moves += gen_rook_type_moves(@side, r)
    end
    moves
  end

  def gen_bishop_type_moves(side, index, start_limit = 8)
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
          moves << Move.new(colored_piece(BISHOP,side), index, target, capture)
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

  def gen_bishops_moves white
    moves = []
    bishops = @bitboards[colored_piece(BISHOP,side)]
    indexes(bishops).each do |r|
      moves += gen_bishop_type_moves(@side, r)
    end
    moves
  end
end

