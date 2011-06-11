require 'constants'

module MyTeacherUtils

  include Constants

  # 'b' => BBISHOP
  def symbol_to_piece(sym)
    SYMBOLS.index(sym)
  end

  # BBISHOP => 'b'
  def piece_to_symbol(piece)
    SYMBOLS[piece]
  end


  # "a1" => 0
  def case_to_index(c)
    SQUARENAME.index(c)
  end

  # 0 => "a1"
  def index_to_case(c)
    SQUARENAME[c]
  end

  # return KING for WKING or BKING (or KING)
  def piece_type(piece)
    return piece if piece < BLACKS_OFFSET
    piece - BLACKS_OFFSET
  end

  # return the numeric value of the piece
  # can pass KING / WKING / BKING, it works any way
  def piece_value(p)
    VALUES[piece_type(p)]
  end

  def colored_piece(piece, side)
    # quicker than below....
    if side == BLACK
      return piece if piece >= BLACKS_OFFSET
      return piece + BLACKS_OFFSET
    else
      return piece if piece < BLACKS_OFFSET
      return piece - BLACKS_OFFSET
    end
    #piece = piece_type(piece)
    #piece + (side == BLACK ? BLACKS_OFFSET : 0)
  end

  def color(piece)
    return WHITE if piece <= WPAWN
    return BLACK
  end

  def pretty_time(secs)
    return "#{round(secs)}s" if secs < 60
    min = (secs.to_f / 60).floor
    return "#{min}m#{round(secs-min*60,1)}" if min < 60
    hour = (min.to_f / 60).floor
    "#{hour}h#{min-hour*60}m#{round(secs-min*60,1)}"
  end

  def round(n, f=0.1)
    (n / f).round * f
  end

  def time_it
    t = Time.now
    rv = yield
    puts Time.now-t
    rv
  end

  def dec2bin(n)
    n.to_s(2)
  end

  def bin2dec(number)
    Integer("0b"+number)
  end

  def print_board(bb)
    ind = indexes(bb)
    i = 0
    [56,48,40,32,24,16,8,0].each { |i|
      (0..7).each { |j|
        p = ind.include?(i+j)
        if p
          print ' X |'
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

end

