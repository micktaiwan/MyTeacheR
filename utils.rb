require 'constants'

module MyTeacherUtils

  include Constants

  # 'b' => BBISHOP
  def symbol_to_piece(sym)
    SYMBOLS.index(sym)
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
    piece + (side == BLACK ? BLACKS_OFFSET : 0)
  end

  def color(piece)
    return WHITE if piece <= WPAWN
    return BLACK
  end

  def pretty_time(secs)
    return "#{round(secs)}s" if secs < 60
    min = (secs.to_f / 60).floor
    return "#{min}m #{round(secs-min*60)}s" if min < 60
    hour = (min.to_f / 60).floor
    "#{hour}h#{min-hour*60}:#{round(secs-min*60,1)}s"
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

  # useless :)
  def dec2bin(number)
    number = Integer(number);
    if(number == 0)
      return 0;
    end
    ret_bin = "";
    # Until val is zero, convert it into binary format
    while(number != 0)
      ret_bin = String(number % 2) + ret_bin;
      number = number / 2;
    end
    return ret_bin;
  end

end

