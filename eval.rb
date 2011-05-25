require 'constants'

class Search

  include Constants

  def eval(pos)
    eval_material(pos)# +
    #eval_mobility(pos)
  end

  def eval_material(pos)
	  white = PAWN_VALUE * pos.num_pieces(WPAWN) +
        		QUEEN_VALUE * pos.num_pieces(WQUEEN) +
        		ROOK_VALUE * pos.num_pieces(WROOK) +
        		BISHOP_VALUE * pos.num_pieces(WBISHOP) +
        		KNIGHT_VALUE * pos.num_pieces(WKNIGHT)
	  black = PAWN_VALUE * pos.num_pieces(BPAWN) +
        		QUEEN_VALUE * pos.num_pieces(BQUEEN) +
        		ROOK_VALUE * pos.num_pieces(BROOK) +
        		BISHOP_VALUE * pos.num_pieces(BBISHOP) +
        		KNIGHT_VALUE * pos.num_pieces(BKNIGHT)
	  white - black
  end

  def eval_mobility(pos)
    pos.gen_moves.size.to_f / 100
  end

end

