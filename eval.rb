require 'constants'

class Search

  include Constants

  def evaluate
    eval_material + eval_position + eval_mobility
  end

  def eval_material
	  white = PAWN_VALUE    * @p.num_pieces(WPAWN) +
        		QUEEN_VALUE   * @p.num_pieces(WQUEEN) +
        		ROOK_VALUE    * @p.num_pieces(WROOK) +
        		BISHOP_VALUE  * @p.num_pieces(WBISHOP) +
        		KNIGHT_VALUE  * @p.num_pieces(WKNIGHT) +
        		KING_VALUE    * @p.num_pieces(WKING)
	  black = PAWN_VALUE    * @p.num_pieces(BPAWN) +
        		QUEEN_VALUE   * @p.num_pieces(BQUEEN) +
        		ROOK_VALUE    * @p.num_pieces(BROOK) +
        		BISHOP_VALUE  * @p.num_pieces(BBISHOP) +
        		KNIGHT_VALUE  * @p.num_pieces(BKNIGHT) +
        		KING_VALUE    * @p.num_pieces(BKING)
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

end

