require 'constants'

class Search

  include Constants

  def evaluate
    eval_material + eval_mobility
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

  def eval_mobility
    (@p.gen_moves(WHITE).size-@p.gen_moves(BLACK).size).to_f / 100
  end

end

