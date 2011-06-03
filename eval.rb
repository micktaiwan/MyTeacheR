require 'constants'

class Search

  include Constants
  include MyTeacherUtils

  def evaluate
    eval_material + eval_position + eval_mobility #+ eval_repetition
  end

  def eval_material
	  white = piece_value(PAWN)    * @p.num_pieces(WPAWN) +
        		piece_value(QUEEN)   * @p.num_pieces(WQUEEN) +
        		piece_value(ROOK)    * @p.num_pieces(WROOK) +
        		piece_value(BISHOP)  * @p.num_pieces(WBISHOP) +
        		piece_value(KNIGHT)  * @p.num_pieces(WKNIGHT) +
        		piece_value(KING)    * @p.num_pieces(WKING)
	  black = piece_value(PAWN)    * @p.num_pieces(BPAWN) +
        		piece_value(QUEEN)   * @p.num_pieces(BQUEEN) +
        		piece_value(ROOK)    * @p.num_pieces(BROOK) +
        		piece_value(BISHOP)  * @p.num_pieces(BBISHOP) +
        		piece_value(KNIGHT)  * @p.num_pieces(BKNIGHT) +
        		piece_value(KING)    * @p.num_pieces(BKING)
	  white - black
  end

  def eval_position
    white = @p.indexes(@p.bitboards[WHITE_PAWNS]).inject(0) { |sum, i| WPAWN_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[WHITE_KNIGHTS]).inject(0) { |sum, i| WKNIGHT_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[WHITE_BISHOPS]).inject(0) { |sum, i| WBISHOP_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[WHITE_ROOKS]).inject(0)   { |sum, i| WROOK_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[WHITE_QUEENS]).inject(0)  { |sum, i| WQUEEN_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[WHITE_KING]).inject(0)    { |sum, i| WKING_MG_TABLE[i] + sum }
    # TODO: take in to account end game

    black = @p.indexes(@p.bitboards[BLACK_PAWNS]).inject(0) { |sum, i| BPAWN_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[BLACK_KNIGHTS]).inject(0) { |sum, i| BKNIGHT_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[BLACK_BISHOPS]).inject(0) { |sum, i| BBISHOP_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[BLACK_ROOKS]).inject(0)   { |sum, i| BROOK_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[BLACK_QUEENS]).inject(0)  { |sum, i| BQUEEN_TABLE[i] + sum } +
    @p.indexes(@p.bitboards[BLACK_KING]).inject(0)    { |sum, i| BKING_MG_TABLE[i] + sum }
    white - black
  end

  def eval_mobility
    (@p.gen_moves(WHITE).size-@p.gen_moves(BLACK).size)
  end

  def eval_repetition
    return 0 if @p.hply > 8
    return 0 if @p.history.size < 4
    last1, = @p.history[-1]
    last2, = @p.history[-3]
    if last1.from == last2.to
      #puts "#{last2} => #{last1}"
      #gets
      one = -40
    else
      one = 0
    end
    #last1, = @p.history[-2]
    #last2, = @p.history[-4]
    #if last1.from == last2.to
    #  two = -40
    #else
    #  two = 0
    #end
    #if @p.side==WHITE
    #  return one-two
    #else
    #  return two-one
    #end
    one
  end

end

