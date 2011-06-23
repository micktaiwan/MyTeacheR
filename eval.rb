#require 'constants'

class Position

  #include Constants
  #include MyTeacherUtils

  def evaluate
    #@stats.start_special(:evaluate)
    #rv = eval_material + eval_position + eval_mobility #+ eval_repetition
    #@stats.end_special(:evaluate)
    #rv
    eval_material + eval_position
  end

  def eval_material
    white = piece_value(PAWN)    * num_pieces(WPAWN) +
        piece_value(QUEEN)   * num_pieces(WQUEEN) +
        piece_value(ROOK)    * num_pieces(WROOK) +
        piece_value(BISHOP)  * num_pieces(WBISHOP) +
        piece_value(KNIGHT)  * num_pieces(WKNIGHT) +
        piece_value(KING)    * num_pieces(WKING)
    black = piece_value(PAWN)    * num_pieces(BPAWN) +
        piece_value(QUEEN)   * num_pieces(BQUEEN) +
        piece_value(ROOK)    * num_pieces(BROOK) +
        piece_value(BISHOP)  * num_pieces(BBISHOP) +
        piece_value(KNIGHT)  * num_pieces(BKNIGHT) +
        piece_value(KING)    * num_pieces(BKING)
    white - black
  end

  def eval_position
    white = indexes(bitboards[WHITE_PAWNS]).inject(0) { |sum, i| WPAWN_TABLE[i] + sum } +
    indexes(bitboards[WHITE_KNIGHTS]).inject(0) { |sum, i| WKNIGHT_TABLE[i] + sum } +
    indexes(bitboards[WHITE_BISHOPS]).inject(0) { |sum, i| WBISHOP_TABLE[i] + sum } +
    indexes(bitboards[WHITE_ROOKS]).inject(0)   { |sum, i| WROOK_TABLE[i] + sum } +
    indexes(bitboards[WHITE_QUEENS]).inject(0)  { |sum, i| WQUEEN_TABLE[i] + sum } +
    indexes(bitboards[WHITE_KING]).inject(0)    { |sum, i| WKING_MG_TABLE[i] + sum }
    # TODO: take in to account end game

    black = indexes(bitboards[BLACK_PAWNS]).inject(0) { |sum, i| BPAWN_TABLE[i] + sum } +
    indexes(bitboards[BLACK_KNIGHTS]).inject(0) { |sum, i| BKNIGHT_TABLE[i] + sum } +
    indexes(bitboards[BLACK_BISHOPS]).inject(0) { |sum, i| BBISHOP_TABLE[i] + sum } +
    indexes(bitboards[BLACK_ROOKS]).inject(0)   { |sum, i| BROOK_TABLE[i] + sum } +
    indexes(bitboards[BLACK_QUEENS]).inject(0)  { |sum, i| BQUEEN_TABLE[i] + sum } +
    indexes(bitboards[BLACK_KING]).inject(0)    { |sum, i| BKING_MG_TABLE[i] + sum }
    white - black
  end

  def eval_mobility
    (gen_moves(WHITE).size-gen_moves(BLACK).size)
  end

  def eval_repetition
    return 0 if hply > 8
    return 0 if history.size < 4
    last1, = history[-1]
    last2, = history[-3]
    if last1.from == last2.to
      #puts "#{last2} => #{last1}"
      #gets
      one = -40
    else
      one = 0
    end
    #last1, = history[-2]
    #last2, = history[-4]
    #if last1.from == last2.to
    #  two = -40
    #else
    #  two = 0
    #end
    #if side==WHITE
    #  return one-two
    #else
    #  return two-one
    #end
    one
  end

end

