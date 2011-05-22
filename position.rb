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
    @all_whites = @all_blacks = @all_pieces = 0
    @side   = WHITE
    @ep     = -1
    @fifty  = @ply = @hply = 0
    @history = []
    @bitboards[CAN_CASTLE] = 0x000F # 1111
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
          print ' ' + SYMBOLS[p] + ' |'
        else
          if (i+j)%2 == 0
            print '   |'
          else
            print '   |' # white
          end
        end
        }
      puts
      }
    puts
  end

  def increment_ply(inc=1)
    @ply += inc
    @hply = @ply/2
  end

  def move_piece(piece, from, to)
		unset(piece, from)
    set(piece, to)
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

		# handle castling
		if(piece_type(move.piece) == KING and (move.to - move.from).abs == 2)
		  puts "castling!"
			case move.to
				when 62
					move_piece(BROOK, 63, 61)
				when 58
					move_piece(BROOK, 56, 59)
				when 2
					move_piece(WROOK, 0, 3)
				when 6
					move_piece(WROOK, 7, 5)
			end
		end

		# mark no-longer-possible castles
		move.can_castle = @bitboards[CAN_CASTLE] # backup
		if move.piece == BKING
			@bitboards[CAN_CASTLE] &= ~(1|2)
		elsif move.piece == BROOK and move.from == 56
			@bitboards[CAN_CASTLE] &= ~(1)
		elsif move.piece == BROOK and move.from == 63
			@bitboards[CAN_CASTLE] &= ~(2)
		elsif move.piece == WKING
			@bitboards[CAN_CASTLE] &= ~(4|8)
		elsif move.piece == WROOK and move.from == 0
			@bitboards[CAN_CASTLE] &= ~(4)
		elsif move.piece == WROOK and move.from == 7
			@bitboards[CAN_CASTLE] &= ~(8)
		end

		mark_enpassant(move.piece, move.from, move.to)

    increment_ply
    @history << move
    @side = 1-@side
  end

  def unmake
		move = @history.pop
		return unless move
		set(move.piece, move.from)

		if(move.promotion) then unset(move.promotion, move.to)
		else unset(move.piece, move.to) end

		if(move.capture) then set(move.capture, move.to) end

		if last = @history.last
			mark_enpassant(last.piece, last.from, last.to)
		else
			mark_enpassant(nil, nil, nil)
		end

		# handle castling
		@bitboards[CAN_CASTLE] = move.can_castle
		# are we castling?
		if(piece_type(move.piece) == KING and (move.to - move.to).abs == 2)
			case move.to
				when 62
					move_piece(BROOK, 61, 63)
				when 58
					move_piece(BROOK, 59, 56)
				when 2
					move_piece(WROOK, 3, 0)
				when 6
					move_piece(WROOK, 5, 7)
			end
		end

    increment_ply(-1)
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

	def mark_enpassant(last_piece, last_orig, last_dest)
		if last_piece == BPAWN and last_orig > 47 and last_orig < 56 and
			@bitboards[ENPASSANT] = ( 1 << last_orig+8)
		elsif last_piece == WPAWN and last_orig > 7 and last_orig < 16 and
			@bitboards[ENPASSANT] = ( 1 << last_orig+8)
		else
			@bitboards[ENPASSANT] = 0
		end
	end


  def piece_type(piece)
    return piece if piece < BLACKS_OFFSET
    piece - BLACKS_OFFSET
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

	def can_castle(side, castle_side)
		@bitboards[CAN_CASTLE] & (1 << ((side * 2)+castle_side)) > 0
	end

end

