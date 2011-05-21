require 'constants'
require 'move'
load './generator.rb'

class Position

  include Constants

  attr_reader :white_king, :white_queens,:white_rooks,:white_bishops,:white_knights,:white_pawns,:black_king,:black_queens,:black_rooks,:black_bishops,:black_knights,:black_pawns,:all_pieces
  attr_reader :played_move, :ply, :hply, :history, :side

  def initialize
		@bitboards = Array.new(LAST_BOARD_INDEX+1, 0)
    reset_to_starting_position
  end

  def empty_position!
    (WHITE_KING..BLACK_PAWNS).each { |i|
      @bitboards[i] = 0
      }
    @all_whites     = 0
    @all_blacks     = 0
    @all_pieces     = 0
    @side   = WHITE
    @castle = CK|CQ|Ck|Cq
    @ep     = -1
    @fifty  = 0
    @ply    = 0
    @hply   = 0
    @played_move    = nil
    @history = []
  end

  def is_empty?
    @all_pieces == 0b0
  end

  def reset_to_starting_position
    empty_position!
    @bitboards[WHITE_PAWNS]   = 0b0000000000000000000000000000000000000000000000001111111100000000
    @bitboards[WHITE_ROOKS]   = 0b0000000000000000000000000000000000000000000000000000000010000001
    @bitboards[WHITE_KNIGHTS] = 0b0000000000000000000000000000000000000000000000000000000001000010
    @bitboards[WHITE_BISHOPS] = 0b0000000000000000000000000000000000000000000000000000000000100100
    @bitboards[WHITE_QUEENS]  = 0b0000000000000000000000000000000000000000000000000000000000001000
    @bitboards[WHITE_KING]    = 0b0000000000000000000000000000000000000000000000000000000000010000
    @bitboards[BLACK_PAWNS]   = 0b0000000011111111000000000000000000000000000000000000000000000000
    @bitboards[BLACK_ROOKS]   = 0b1000000100000000000000000000000000000000000000000000000000000000
    @bitboards[BLACK_KNIGHTS] = 0b0100001000000000000000000000000000000000000000000000000000000000
    @bitboards[BLACK_BISHOPS] = 0b0010010000000000000000000000000000000000000000000000000000000000
    @bitboards[BLACK_QUEENS]  = 0b0000100000000000000000000000000000000000000000000000000000000000
    @bitboards[BLACK_KING]    = 0b0001000000000000000000000000000000000000000000000000000000000000
    @all_whites     = (WHITE_KING..WHITE_PAWNS).inject(0) { |sum, index| @bitboards[index] + sum }
    @all_blacks     = (BLACK_KING..BLACK_PAWNS).inject(0) { |sum, index| @bitboards[index] + sum }
    @all_pieces     = @all_whites | @all_blacks
  end

  def play
    @ply += 1
    @hply = @ply/2
    m = Move.new
    m.set(1,18) # Kc3
    # m = Search.get_best_move
    @history << m
    @played_move = m
    true
  end

  def print_moves(moves)
    moves.map { |m| "#{SQUARENAME[m[0]]}#{SQUARENAME[m[1]]}" }.join(", ")
  end

private

	# give indexes of all ones in the bitboard
	def indexes(bb)
		(0..63).select {|i| ((1 << i) & bb) != 0}
	end

	def piece_at(index)
		bit = (1 << index)
		if @all_pieces & bit > 0
  		if @all_whites & bit > 0
  		  (KING..PAWN).each { |piece|
    			return [piece,WHITE] if (@bitboards[piece] & bit) > 0
    			}
  		elsif @all_blacks & bit > 0
  		  (KING..PAWN).each { |piece|
    			return [piece,BLACK] if (@bitboards[piece+BLACKS_OFFSET] & bit) > 0
    			}
  		end
		end
		return nil
	end

end

