require 'constants'
require 'move'
load './generator.rb'

class Position

  include Constants

  attr_reader :white_king, :white_queens,:white_rooks,:white_bishops,:white_knights,:white_pawns,:black_king,:black_queens,:black_rooks,:black_bishops,:black_knights,:black_pawns,:all_pieces
  attr_reader :ply, :hply, :history, :side

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
    @bitboards[ENPASSANT]     = 0
    update_sum_boards
  end

  def update_sum_boards
    @all_whites     = (WHITE_KING..WHITE_PAWNS).inject(0) { |sum, index| @bitboards[index] + sum }
    @all_blacks     = (BLACK_KING..BLACK_PAWNS).inject(0) { |sum, index| @bitboards[index] + sum }
    @all_pieces     = @all_whites | @all_blacks
  end


  def print_moves(moves)
    moves.map { |m| "#{SQUARENAME[m.from]}#{SQUARENAME[m.to]}" }.join(", ")
  end

  def print_board
    i = 0
    [56,48,40,32,24,16,8,0].each { |i|
      (0..7).each { |j|
        p = piece_at(i+j)
        if p
          print SYMBOLS[p]
        else
          print '*'
        end
        }
      puts
      }
    puts
  end

  def increment_ply
    @ply += 1
    @hply = @ply/2
  end

  def make(move)
    raise "no move" if move.from==nil or move.to==nil
	  unset(move.capture, move.to) if move.capture
		unset(move.piece, move.from)
		if !move.promotion
		  set(move.piece, move.to)
		else
		  set(move.promotion, move.to)
		end
    increment_ply
    @history << move
    @side = 1-@side
  end

	def set(piece, *indexes)
		indexes.each do |i|
  		pos = (1 << i)
      @bitboards[piece] |= pos
		end
    update_sum_boards
	end

	def unset(piece, *indexes)
		indexes.each do |i|
			pos = ~(1 << i)
			@bitboards[piece] &= pos
		end
    update_sum_boards
	end

	def piece_at(index)
		bit = (1 << index)
		if @all_pieces & bit > 0
  		if @all_whites & bit > 0
  		  (KING..PAWN).each { |piece|
    			return piece if (@bitboards[piece] & bit) > 0
    			}
  		elsif @all_blacks & bit > 0
  		  (BKING..BPAWN).each { |piece|
    			return piece if (@bitboards[piece] & bit) > 0
    			}
  		end
		end
		return nil
	end

	# give indexes of all ones in the bitboard
	def indexes(bb)
		(0..63).select {|i| ((1 << i) & bb) != 0}
	end

end

