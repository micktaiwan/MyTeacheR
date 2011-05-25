require 'constants'
require 'utils'
require 'move'
load './generator.rb'

class Position

  include Constants
  include MyTeacherUtils

  attr_reader :all_pieces, :bitboards
  attr_reader :ply, :hply, :history, :side, :hclock

  def initialize
		@bitboards = Array.new(LAST_BOARD_INDEX+1, 0)
    reset_to_starting_position
  end

  def empty!
    (WHITE_KING..BLACK_PAWNS).each { |i|
      @bitboards[i] = 0
      }
    @all_whites = @all_blacks = @all_pieces = 0
    @side   = WHITE
    @ep     = -1
    @ply = @hclock = 0
    @hply = 1
    @history = []
  end

  def is_empty?
    @all_pieces == 0b0
  end

  def reset_to_starting_position
    empty!
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
    @bitboards[CAN_CASTLE]    = 0x000F # 1111
    update_sum_boards
  end

  def update_sum_boards
    @all_whites     = (WHITE_KING..WHITE_PAWNS).inject(0) { |sum, index| @bitboards[index] + sum }
    @all_blacks     = (BLACK_KING..BLACK_PAWNS).inject(0) { |sum, index| @bitboards[index] + sum }
    @all_pieces     = @all_whites | @all_blacks
  end

	def dump
		@bitboards[@bitboards.size] = @history
		@bitboards[@bitboards.size] = @side
		@bitboards[@bitboards.size] = @hply
		@bitboards[@bitboards.size] = @ply
		@bitboards[@bitboards.size] = @hclock
		ret = Marshal.dump(@bitboards)
		(1..5).each { @bitboards.delete_at(@bitboards.size-1) }
		ret
	end

	def load(dmp)
		@bitboards  = Marshal.load( dmp)
		@hclock     = @bitboards.pop
		@ply        = @bitboards.pop
		@hply       = @bitboards.pop
		@side       = @bitboards.pop
		@history    = @bitboards.pop
		update_sum_boards
		self
	end

	def ==(pos)
	  @all_pieces == pos.all_pieces and
		@history == pos.history and
		@side == pos.side and
		@hply == pos.hply and
		@ply == pos.ply and
		@hclock == pos.hclock
	end

  def print_moves(moves)
    moves.map { |m| "#{SQUARENAME[m.from]}#{SQUARENAME[m.to]}" }.join(", ")
  end

  def printp
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
    @hply = @ply/2 + 1
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

    if piece_type(move.piece) != PAWN and move.capture == nil
      @hclock += 1
    else
      @hclock = 0
    end
    @history << [move, @hclock]
		mark_enpassant(move.piece, move.from, move.to)
    increment_ply
    @side = 1-@side
  end

  def unmake
		move, = @history.pop
		return unless move

		if(move.promotion) then unset(move.promotion, move.to)
		else unset(move.piece, move.to) end
		set(move.piece, move.from)

		set(move.capture, move.to) if(move.capture)

		# handle castling
		@bitboards[CAN_CASTLE] = move.can_castle
		# are we castling?
		if(piece_type(move.piece) == KING and (move.to - move.from).abs == 2)
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

		if last = @history.last
			mark_enpassant(last[0].piece, last[0].from, last[0].to)
    	@hclock = last[1]
		else
			mark_enpassant(nil, nil, nil)
    	@hclock = 0
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

  # return the number of piece in this position
  def num_pieces(piece)
    indexes(@bitboards[piece]).size
  end

	# Load Forsyth-Edwards Notation (FEN)
	def load_fen(str)
	  empty!
	  state = :pieces
	  castle = 0
	  i   = 0
	  pos = 56
	  loop do
	    if str[i].chr == ' '
	      case state
        when :pieces
          state = :side
        when :side
          state = :castle
        when :castle
    	    state = :enpassant
        when :enpassant
    	    state = :hclock
        when :hclock
    	    state = :ply
    	  end
        i += 1
    	end
    	case state
	    when :pieces
	      c = str[i]
	      case
        when c.chr == '/'
          i += 1
          pos -= 8*2
        when (c.chr >= 'B' and c.chr <='r')
          set(symbol_to_piece(c.chr), pos)
          i += 1
          pos += 1
        when (c.chr >= '1' and c.chr <= '8')
          i += 1
          pos += (c - 48)
        else
          raise "can not read this FEN position. c=#{c}/#{c.chr}, FEN=#{str}"
        end
      when :side
        @side = (str[i].chr=='w')? WHITE : BLACK
        i += 1
      when :castle
        loop do
          case str[i].chr
          when ' '
            break
          when '-'
            i += 1
            break
          when 'Q'
            castle |= 1
          when 'K'
            castle |= 2
          when 'q'
            castle |= 4
          when 'k'
            castle |= 8
          else
            raise "can not read this FEN position, because of encastle right misreading #{str}"
          end
          i += 1
        end
      when :enpassant
    	  c = str[i,2]
    	  if c == "- "
    			@bitboards[ENPASSANT] = 0
          i += 1
    	  else
    			@bitboards[ENPASSANT] = ( 1 << case_to_index(c))
          i += 2
    	  end
      when :hclock
    	  @hclock = str[i,2].scan(/\d+/)[0].to_i
        i += @hclock.to_s.size
    	when :ply
    	  @ply = str[i,3].scan(/\d+/)[0].to_i
    	  @hply = ((@ply-1) * 2) + ((@side == BLACK)? 1 : 0)
    	  break
    	else
        raise "can not read this FEN position #{str}"
    	end
    end
    update_sum_boards
    @bitboards[CAN_CASTLE] = castle
	end

end

